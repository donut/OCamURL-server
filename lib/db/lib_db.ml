
open Lwt.Infix

module Delete = Delete
module Insert = Insert
module Select = Select
module Update = Update

let make_connect_func ?host ?user ?pass ?db ?port ?socket ?flags () : Handle.t =
	`Connect (fun () ->
		Mdb.connect ?host ?user ?pass ?db ?port ?socket ?flags ()
		>>= Util.or_die "conect" >>= fun c -> Lwt.return @@ `Connection c)

let get_connection = Handle.get_connection

let close = Handle.close

let close_if_prev_not_connected = Handle.close_if_prev_not_connected

let final_close = Mdb.library_end

let or_die = Util.or_die