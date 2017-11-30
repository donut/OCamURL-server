
open Core

let is_file path =
	match Sys.is_file path with
	| `Yes -> true
	| _ -> false