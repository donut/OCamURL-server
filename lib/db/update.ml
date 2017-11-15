
open Lib_model
open Lwt.Infix
open Util

let alias_name db_conn name new_name =
	let query = "UPDATE alias SET name = ? WHERE name = ? LIMIT 1" in
	let values = [| `String new_name; `String name; |] in
	execute_query db_conn query values lwt_unit

let alias_status db_conn name status =
	let query = "UPDATE alias SET status = ? WHERE name = ? LIMIT 1" in
	let values = [|
		`String (Alias.Status.to_string status);
		`String name;
	|] in
	execute_query db_conn query values lwt_unit

let alias_url db_conn name url_id =
	let query = "UPDATE alias SET url = ? WHERE name = ? LIMIT 1" in
	let values = [|
		`Int url_id;
		`String name;
	|] in
	execute_query db_conn query values lwt_unit
