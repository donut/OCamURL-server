
open Lib_model
open Lwt.Infix
open Util

let alias_name db_connect name new_name =
	let query = "UPDATE alias SET name = ? WHERE name = ? LIMIT 1" in
	let values = [| `String new_name; `String name; |] in
	connect_and_exec db_connect query values lwt_unit

let alias_status db_connect name status =
	let query = "UPDATE alias SET status = ? WHERE name = ? LIMIT 1" in
	let values = [|
		`String (Alias.Status.to_string status);
		`String name;
	|] in
	connect_and_exec db_connect query values lwt_unit

let alias_url db_connect name url_id =
	let query = "UPDATE alias SET url = ? WHERE name = ? LIMIT 1" in
	let values = [|
		`Int url_id;
		`String name;
	|] in
	connect_and_exec db_connect query values lwt_unit
