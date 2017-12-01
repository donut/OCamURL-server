
open Lib_model
open Lwt.Infix
open Printf
open Util

exception Last_inserted_ID_missing of string
let get_last_insert_id db_conn query =
  let query = "SELECT LAST_INSERT_ID() as id" in
  execute db_conn query [||] Select.id_of_first_row >>= (function
  | None -> raise (Last_inserted_ID_missing query)
  | Some id -> Lwt.return id)

let exec_and_get_id db_connect query values =
  db_connect () >>= fun conn ->
  execute conn query values lwt_unit >>= fun () ->
  get_last_insert_id conn query >>= fun id ->
  Mdb.close conn >>= fun () ->
  Lwt.return id

let single_row_query table field_list =
  let join = String.concat ", " in
  let fields = join field_list in
  let placeholders = field_list |> List.map (fun _ -> "?") |> join in
  sprintf "INSERT INTO `%s` (%s) VALUES (%s)" table fields placeholders

let alias db_connect alias' =
  let query = single_row_query "alias" alias_fields in
  exec_and_get_id db_connect query (values_of_alias alias')

let url connection url' = 
  let query = single_row_query "url" url_fields in
  exec_and_get_id connection query (values_of_url url')

exception Just_inserted_URL_missing of string

let url_if_missing db_connect url' =
  Select.id_of_url db_connect url' >>= function
  | Some id -> Lwt.return id
  | None -> url db_connect url'

let use db_conn use' =
  let query = single_row_query "use" use_fields in
  exec_and_get_id db_conn query (values_of_use use')