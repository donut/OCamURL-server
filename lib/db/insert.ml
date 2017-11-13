
open Lib_model
open Lwt.Infix
open Util

let single_row_query table field_list =
  let join = String.concat ", " in
  let fields = join field_list in
  let placeholders = field_list |> List.map (fun _ -> "?") |> join in
  "INSERT INTO " ^ table ^ " (" ^ fields ^ ") VALUES (" ^ placeholders ^ ")"

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