
open Lib_model
open Lwt.Infix
open Printf
open Util

exception Last_inserted_ID_missing of string
let get_last_insert_id db_conn query =
  let query = "SELECT LAST_INSERT_ID() as id" in
  execute_query db_conn query [||] Select.id_of_first_row >>= function
  | None -> raise (Last_inserted_ID_missing query)
  | Some id -> Lwt.return id

let single_row_query table field_list =
  let join = String.concat ", " in
  let fields = join field_list in
  let placeholders = field_list |> List.map (fun _ -> "?") |> join in
  sprintf "INSERT INTO `%s` (%s) VALUES (%s)" table fields placeholders

let alias connection alias' =
  let query = single_row_query "alias" alias_fields in
  execute_query connection query (values_of_alias alias') lwt_unit

let url connection url' = 
  let query = single_row_query "url" url_fields in
  execute_query connection query (values_of_url url') lwt_unit

exception Just_inserted_URL_missing of string

let url_if_missing db_conn url' =
  Select.id_of_url db_conn url' >>= function
  | Some id -> Lwt.return id
  | None -> url db_conn url' >>= fun () ->
    Select.id_of_url db_conn url' >>= function
    | Some id -> Lwt.return id
    | None -> raise (Just_inserted_URL_missing (Url.to_string url'))

let use db_conn use' =
  let query = single_row_query "use" use_fields in
  execute_query db_conn query (values_of_use use') lwt_unit >>= fun () ->
  get_last_insert_id db_conn query