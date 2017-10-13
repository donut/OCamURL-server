
open Util
open Lib_model
open Printf

let single_row_query table field_list =
  let join = String.concat ", " in
  let fields = join field_list in
  let placeholders = field_list |> List.map (fun _ -> "?") |> join in
  "INSERT INTO " ^ table ^ " (" ^ fields ^ ") VALUES (" ^ placeholders ^ ")"


let alias connection alias' =
  let query = single_row_query "alias" alias_fields in
  execute_query connection query (values_of_alias alias') (fun _ -> ())


let url connection url' = 
  let query = single_row_query "url" url_fields in
  execute_query connection query (values_of_url url') (fun _ -> ())