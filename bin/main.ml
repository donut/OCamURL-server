
module DB = Lib.DB
module Gql = Graphql_lwt
module Schema = Lib.Schema


let schema db_connection = Gql.Schema.(Schema.(schema [
    Url_qry.field db_connection;
  ]
  ~mutations:[
    Put_alias_mut.field db_connection;
  ]
))

(* let () =
  let connection = DB.connect
    ~host:"localhost" ~user:"root" ~pass:"" ~db:"rtmDOTtv" ()
    |> Lib.DB.or_die "connect"
  in

  Gql.Server.start ~ctx:(fun () -> ()) (schema connection) |> Lwt_main.run;

  DB.close connection; *)

open Lwt.Infix
open Printf

module S = Mariadb.Nonblocking.Status
module M = Mariadb.Nonblocking.Make(struct
  module IO = struct
    type 'a future = 'a Lwt.t
    let (>>=) = (>>=)
    let return = Lwt.return
  end

  let wait mariadb status =
    let fd = Lwt_unix.of_unix_file_descr @@ Mariadb.Nonblocking.fd mariadb in
    assert (S.read status || S.write status || S.timeout status);
    let idle, _ = Lwt.task () in
    let rt =
      if S.read status then Lwt_unix.wait_read fd
      else idle in
    let wt =
      if S.write status then Lwt_unix.wait_write fd
      else idle in
    let tt =
      match S.timeout status, Mariadb.Nonblocking.timeout mariadb with
      | true, 0 -> Lwt.return ()
      | true, tmout -> Lwt_unix.timeout (float tmout)
      | false, _ -> idle in
    Lwt.catch
      (fun () ->
        Lwt.nchoose [rt; wt; tt] >>= fun _ ->
        Lwt.return @@
          S.create
            ~read:(Lwt_unix.readable fd)
            ~write:(Lwt_unix.writable fd)
            ())
      (function
      | Lwt_unix.Timeout -> Lwt.return @@ S.create ~timeout:true ()
      | e -> Lwt.fail e)
end)

let env var def =
  try Sys.getenv var
  with Not_found -> def

let or_die where = function
  | Ok r -> Lwt.return r
  | Error (i, e) -> Lwt.fail_with @@ sprintf "%s: (%d) %s" where i e

let print_row row =
  Lwt_io.printf "---\n%!" >>= fun () ->
  M.Row.StringMap.fold
    (fun name field _ ->
      Lwt_io.printf "%20s " name >>= fun () ->
      match M.Field.value field with
      | `Int i -> Lwt_io.printf "%d\n%!" i
      | `Float x -> Lwt_io.printf "%f\n%!" x
      | `String s -> Lwt_io.printf "%s\n%!" s
      | `Bytes b -> Lwt_io.printf "%s\n%!" (Bytes.to_string b)
      | `Time t ->
          Lwt_io.printf "%04d-%02d-%02d %02d:%02d:%02d\n%!"
            (M.Time.year t)
            (M.Time.month t)
            (M.Time.day t)
            (M.Time.hour t)
            (M.Time.minute t)
            (M.Time.second t)
      | `Null -> Lwt_io.printf "NULL\n%!")
    row
  Lwt.return_unit

let connect () =
  M.connect ~host:"localhost" ~user:"root" ~pass:"" ~db:"rtmDOTtv" ()

let stream res =
  let next _ =
    M.Res.fetch (module M.Row.Map) res
    >>= function
      | Ok (Some _ as row) -> Lwt.return row
      | Ok None -> Lwt.return_none
      | Error _ -> Lwt.return_none in
  Lwt.return (Lwt_stream.from next)

module Util = struct
  let execute_query conn query values yield =
    M.prepare conn query >>= or_die "prepare" >>= fun stmt ->
    M.Stmt.execute stmt values >>= or_die "exec" >>=
    yield >>= fun return -> 
    M.Stmt.close stmt >>= or_die "stmt close" >>= fun () ->
    Lwt.return return
end

module Select = struct
  let first_row_of_result r = Lwt.catch (fun () ->
    stream r >>= Lwt_stream.next >>= fun r -> Lwt.return_some r)
    (function
      | Lwt_stream.Empty -> Lwt.return_none
      | exn -> Lwt.fail exn)

  let id_of_first_row result =
    let exception ID_not_int in
    first_row_of_result result >>= function
    | None -> Lwt.return_none
    | Some row ->
      match row |> M.Row.StringMap.find "id" |> M.Field.value with
      | `Int id -> Lwt.return_some id
      | _ -> Lwt.fail ID_not_int

  let id_of_alias db_conn name =
    let query = "SELECT id FROM alias WHERE name = ?" in
    let values = [| `String name |] in
    let yield = function
      | None -> Lwt.return_none
      | Some res -> id_of_first_row res
    in
    Util.execute_query db_conn query values yield
end

let main () =
  connect () >>= or_die "connect" >>= fun mariadb ->
  Select.id_of_alias mariadb "bingo2" >>= fun id ->
  let return () = Lwt.return_unit in
  match id with  
  | None -> Lwt_io.printlf "No ID :(" >>= return
  | Some id' -> Lwt_io.printlf "ID: %d" id' >>= return
  >>= fun () ->
  M.close mariadb

let () =
  Lwt_main.run @@ main ()
