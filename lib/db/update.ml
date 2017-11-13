
open Lib_model
open Lwt.Infix
open Util

let alias_name db_conn old_name new_name =
	let query = "UPDATE alias SET name = ? WHERE name = ? LIMIT 1" in
	let values = [| `String new_name; `String old_name; |] in
	execute_query db_conn query values lwt_unit