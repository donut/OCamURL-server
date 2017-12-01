
open Lwt.Infix

type t = 
	[ `Connection of Mdb.t
	| `Connect of unit -> t Lwt.t ]

exception Unexpected_Connect_DB_handle
let close h = match h with 
	| `Connection c -> Mdb.close c
  | `Connect _ -> raise Unexpected_Connect_DB_handle

(** Handle a situation where you're not sure if you created the connection
		and should close it or not.Arg
		
		t represents either a DB connection function or an actual connection. 
		This makes it easy to optimize connecting to the DB while not needing to
		worry about whether or not the lower functions take a connection or a
		connect function. But, sometimes these lower functions need to make a
		connection if it's not already connected. But they want to be sure to close
		the connection if they're the ones who made it, but not if they're  *)
let close_if_prev_not_connected ~(handle:t) ~conn =
	match handle with
	| `Connection _ -> Lwt.return_unit
	| `Connect _ -> close conn

let get_connection (h:t) = match h with
  | `Connection c -> Lwt.return @@ `Connection c
  | `Connect    c -> c ()

let get_raw_connection h = 
	get_connection h >>= function
	| `Connection c -> Lwt.return c
	| `Connect _ -> raise Unexpected_Connect_DB_handle

