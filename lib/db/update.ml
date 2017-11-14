
open Lib_model
open Lwt.Infix
open Util

let alias_name db_conn old_name new_name =
	let query = "UPDATE alias SET name = ? WHERE name = ? LIMIT 1" in
	let values = [| `String new_name; `String old_name; |] in
	execute_query db_conn query values lwt_unit

let alias_status db_conn name status =
	let query = "UPDATE alias SET status = ? WHERE name = ? LIMIT 1" in
	let values = [|
		`String (Alias.Status.to_string status);
		`String name;
	|] in
	execute_query db_conn query values lwt_unit
