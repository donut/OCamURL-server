
open Lwt.Infix

module C = Cohttp_lwt_unix
module Conf = Lib.Config

let router conn (req:Cohttp.Request.t) body = Cohttp.(
	ignore @@ Lwt_io.printf "Req: %s\n" req.resource;
	let path = Request.uri req |> Uri.path in

	match req.meth, path with
	| `GET, ""
	| `GET, "/" -> C.Server.respond_string ~status:`Not_found ~body:"" ()
	| `GET,  _  -> C.Server.respond_string ~status:`OK ~body:"hello" ()
	|    _,  _  -> C.Server.respond_string ~status:`Method_not_allowed ~body:""()
)

let start () =
	let mode = `TCP (`Port 8080) in
	let server = C.Server.make ~callback:router () in
	Lwt_main.run @@ C.Server.create ~mode server

