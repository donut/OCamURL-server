
open Lwt.Infix
open Printf

let lwt_unit _ = Lwt.return_unit

let string_of_value = function 
  | `Int i -> sprintf "int (%d)" i
  | `Float x -> sprintf "float (%f)" x
  | `String s -> sprintf "string (%s)" s
  | `Bytes b -> sprintf "%s" "Bytes! :)"
  | `Time t ->
      sprintf "time (%04d-%02d-%02d %02d:%02d:%02d)"
      (Mdb.Time.year t)
      (Mdb.Time.month t)
      (Mdb.Time.day t)
      (Mdb.Time.hour t)
      (Mdb.Time.minute t)
      (Mdb.Time.second t)
  | `Null -> sprintf "NULL"

let or_die where = function
  | Ok r -> Lwt.return r
  | Error (i, e) -> Lwt.fail_with @@ sprintf "%s: (%d) %s" where i e

let print_row row =
  Lwt_io.printf "---\n%!" >>= fun () ->
  Mdb.Row.StringMap.fold
    (fun name field _ ->
      Lwt_io.printf "%20s " name >>= fun () ->
      match Mdb.Field.value field with
      | `Int i -> Lwt_io.printf "%d\n%!" i
      | `Float x -> Lwt_io.printf "%f\n%!" x
      | `String s -> Lwt_io.printf "%s\n%!" s
      | `Bytes b -> Lwt_io.printf "%s\n%!" (Bytes.to_string b)
      | `Time t ->
          Lwt_io.printf "%04d-%02d-%02d %02d:%02d:%02d\n%!"
            (Mdb.Time.year t)
            (Mdb.Time.month t)
            (Mdb.Time.day t)
            (Mdb.Time.hour t)
            (Mdb.Time.minute t)
            (Mdb.Time.second t)
      | `Null -> Lwt_io.printf "NULL\n%!")
    row
  Lwt.return_unit

let stream res =
  let next _ =
    Mdb.Res.fetch (module Mdb.Row.Map) res
    >>= function
    | Ok (Some _ as row) -> Lwt.return row
    | Ok None -> Lwt.return_none
    | Error _ -> Lwt.return_none in
  Lwt.return (Lwt_stream.from next)

let stream_next_opt s =
  Lwt.catch
    (fun () -> Lwt_stream.next s >>= Lwt.return_some)
    (function
      | Lwt_stream.Empty -> Lwt.return_none
      | exn -> Lwt.fail exn)

let exec_with_conn conn query values yield =
  Mdb.prepare conn query >>= or_die "prepare" >>= fun stmt ->
  Mdb.Stmt.execute stmt values >>= or_die "exec" >>=
  yield >>= fun return -> 
  Mdb.Stmt.close stmt >>= or_die "stmt close" >>= fun () ->
  Lwt.return return

let execute handle query values yield =
  Handle.get_raw_connection handle >>= fun db_conn ->
  exec_with_conn db_conn query values yield >>= fun return ->
  Handle.close_if_prev_not_connected
    ~handle ~conn:(`Connection db_conn) >>= fun () ->
  Lwt.return return

let maybe_string transform maybe = match maybe with
  | None -> `Null
  | Some s -> `String (transform s)

let maybe_int transform maybe = match maybe with
  | None -> `Null
  | Some s -> `Int (transform s)

let alias_fields = [
  "name"; "url"; "status";
]

exception Ref_missing_ID

let values_of_alias (alias:Lib_model.Alias.t) =
  let id = Lib_model.(match alias.url with 
    | Url.ID id
    | Url.URL { id = Some id } -> Url.ID.to_int id
    | Url.URL url -> raise Ref_missing_ID
  ) in

  Lib_model.([|
   `String (Alias.name alias);
   `Int id;
   `String (Alias.status_as_string alias);
  |])

let url_fields = [
  "scheme"; "user"; "password"; "host"; "port"; "path"; "params"; "fragment";
]

let values_of_url url = Lib_model.Url.([|
  `String (Scheme.to_string url.scheme);
  url.user |> maybe_string (Username.to_string);
  url.password |> maybe_string (Password.to_string);
  `String (Host.to_string url.host);
  url.port |> maybe_int (Port.to_int);
  `String (Path.to_string url.path);
  url.params |> maybe_string (Params.to_string) ;
  url.fragment |> maybe_string (Fragment.to_string);
|])

let use_fields = [
  "alias"; "url"; "referrer"; "user_agent"; "ip";
]

let values_of_use (use:Lib_model.Use.t) = Lib_model.(
  let alias_id = match Alias.id_of_ref use.alias with
    | None -> raise Ref_missing_ID
    | Some id -> Alias.ID.to_int id in
  let get_url_id url = match Url.id_of_ref url with
    | None -> raise Ref_missing_ID
    | Some id -> Url.ID.to_int id in
  let url_id = get_url_id use.url in
  let referrer_id = Core.Option.map use.referrer (get_url_id) in

  [|
    `Int alias_id;
    `Int url_id;
    (match referrer_id with | None -> `Null | Some id -> `Int id);
    use.user_agent |> maybe_string (Use.User_agent.to_string);
    `String (Use.IP.to_string use.ip);
  |]
)

let find_map_value row key =
   row |> Mdb.Row.StringMap.find key |> Mdb.Field.value

exception Unexpected_type_for_key of string
let unexpected_type_for_key key expected value =
  Unexpected_type_for_key (key ^ " not " ^ expected ^ "; "
  ^ (string_of_value value))

let string_of_map row key =
   match find_map_value row key with
   | `String value -> value
   | x -> raise (unexpected_type_for_key key "string" x)

let maybe_string_of_map row key transform =
   match find_map_value row key with
   | `Null -> None
   | `String value -> Some (transform value)
   | x -> raise (unexpected_type_for_key key "string or null" x)

let int_of_map row key =
   match find_map_value row key with
   | `Int value -> value
   | x -> raise (unexpected_type_for_key key "int" x)

let maybe_int_of_map row key transform =
   match find_map_value row key with
   | `Null -> None
   | `Int value -> Some (transform value)
   | x -> raise (unexpected_type_for_key key "int or null" x)
