
open Lib_model
open Lwt.Infix
open Util

let alias db_conn name = 
	let query = "DELETE FROM alias WHERE name = ? LIMIT 1" in
	execute_query db_conn query [| `String name |] lwt_unit