
open Lwt.Infix
open Printf

module C = Cohttp_lwt_unix
module Conf = Lib.Config
module DB = Lib.DB
module Model = Lib.Model


let not_found_response ?(alias="") () = 
	let body = match alias with
		| "" -> "Page not found."
		| name -> sprintf "The alias [%s] does not exist." name in
	C.Server.respond_string ~status:`Not_found ~body ()

let resolve_alias db_conn name = Model.Alias.(
	DB.Select.alias_by_name db_conn name >>= function
	| None 
	| Some { status = Status.Disabled } -> not_found_response ~alias:name ()
	| Some { url = url_or_id } -> 

	let exception Alias_missing_URL of string * int in
	Model.Url.(match url_or_id with
		| URL url -> Lwt.return url
		| ID id -> DB.Select.url_by_id db_conn (ID.to_int id) >>= function
			| None -> raise (Alias_missing_URL (name, ID.to_int id))
			| Some url -> Lwt.return url
	) >>= fun url ->

	let uri = Uri.of_string @@ Model.Url.to_string url in
	C.Server.respond_redirect ~uri ()
)

let alias_of_path path = String.(
	if length path > 0 && path.[0] == '/' then
		if length path == 1 then ""
		else sub path 1 (length path - 1) 
	else
		path
)

let router db_conn conn (req:Cohttp.Request.t) body = Cohttp.(
	ignore @@ Lwt_io.printf "Req: %s\n" req.resource;
	let alias = Request.uri req |> Uri.path |> alias_of_path in
	
	match req.meth, alias with
	| `GET, "" -> not_found_response ()
	| `GET,  _ -> resolve_alias db_conn alias
	|    _,  _ -> C.Server.respond_string ~status:`Method_not_allowed ~body:""()
)

let main (conf:Conf.Alias_redirect.t) =
  let db = conf.database in
  DB.connect
    ~host:db.host ~user:db.user ~pass:db.pass ~db:db.database ()
    >>= DB.or_die "connect" >>= fun db_conn ->

	let mode = `TCP (`Port conf.port) in
	let server = C.Server.make ~callback:(router db_conn) () in
	C.Server.create ~mode server >>= fun () ->

  DB.close db_conn

let start (conf:Conf.Alias_redirect.t) =
	Lwt_main.run @@ main conf
