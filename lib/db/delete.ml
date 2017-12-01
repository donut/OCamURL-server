
open Lib_model
open Lwt.Infix
open Util

let alias db_connect name = 
	let query = "DELETE FROM alias WHERE name = ? LIMIT 1" in
	connect_and_exec db_connect query [| `String name |] lwt_unit