
open Lib_model
open Lwt.Infix
open Printf
open Util

let single_row_query table field_list =
  let join = String.concat ", " in
  let fields = join field_list in
  let placeholders = field_list |> List.map (fun _ -> "?") |> join in
  "INSERT INTO " ^ table ^ " (" ^ fields ^ ") VALUES (" ^ placeholders ^ ")"

let lwt_unit _ = Lwt.return_unit

let alias connection alias' =
  let query = single_row_query "alias" alias_fields in
  execute_query connection query (values_of_alias alias') lwt_unit

let url connection url' = 
  let query = single_row_query "url" url_fields in
  execute_query connection query (values_of_url url') lwt_unit