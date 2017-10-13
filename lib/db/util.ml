
open Printf

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

let print_row row =
  let module M = Mariadb.Blocking in
  printf "---\n%!";
  M.Row.StringMap.iter
    (fun name field ->
      printf "%20s " name;
      match M.Field.value field with
      | `Int i -> printf "%d\n%!" i
      | `Float x -> printf "%f\n%!" x
      | `String s -> printf "%s\n%!" s
      | `Bytes b -> printf "%s\n%!" "Bytes! :)"
      | `Time t ->
          printf "%04d-%02d-%02d %02d:%02d:%02d\n%!"
            (M.Time.year t)
          (M.Time.month t)
          (M.Time.day t)
          (M.Time.hour t)
          (M.Time.minute t)
          (M.Time.second t)
    | `Null -> printf "NULL\n%!")
  row


let stream res =
  let module M = Mariadb.Blocking in
  let module F = struct exception E of M.error end in
  let next _ =
    match M.Res.fetch (module M.Row.Map) res with
    | Ok (Some _ as row) -> row
    | Ok None -> None
    | Error e -> raise (F.E e) in
  try Ok (Stream.from next)
  with F.E e -> Error e

let or_die where = function
  | Ok x -> x
  | Error (num, msg) -> failwith @@ sprintf "%s #%d: %s" where num msg 


let maybe_string transform maybe = match maybe with
  | None -> `Null
  | Some s -> `String (transform s)

let maybe_int transform maybe = match maybe with
  | None -> `Null
  | Some s -> `Int (transform s)


let execute_query connection query values yield =
  let stmt = Mdb.prepare connection query |> or_die "prepare" in
  let result = Mdb.Stmt.execute stmt values |> or_die "execute" in
  let return = yield result in
  Mdb.Stmt.close stmt |> or_die "close statement";
  return

let alias_fields = [
  "name"; "url";
]

exception URL_missing_ID

let values_of_alias (alias:Lib_model.Alias.t) =
  let id = match alias.url.id with
    | None -> raise URL_missing_ID
    | Some id -> Lib_model.Url.ID.to_int id
  in
  Lib_model.Alias.([|
   `String (Name.to_string alias.name);
   `Int id
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
