
open Core
open Lwt.Infix
open Printf

module C = Cohttp_lwt_unix
module Cache = Lib.Cache
module Conf = Lib.Config
module DB = Lib.DB
module Model = Lib.Model

let not_found_response ?(alias="") () = 
	let body = match alias with
		| "" -> "Page not found."
		| name -> sprintf "The alias [%s] does not exist." name in
	C.Server.respond_string ~status:`Not_found ~body ()

let url_by_alias db_conn (alias:Model.Alias.t) = Model.(Url.(
	let exception Alias_missing_URL of string * int in
	match alias.url with
	| URL url -> Lwt.return url
	| ID id -> DB.Select.url_by_id db_conn (ID.to_int id) >>= function
		| None -> raise (Alias_missing_URL (Alias.Name.to_string alias.name,
																				ID.to_int id))
		| Some url -> Lwt.return url
))

let record_use db_conn tcp_ch headers (alias:Model.Alias.t) =
	let open Cohttp in 
	let module Opt = Core.Option in 

	begin match Header.get headers "referer" with
		| None -> Lwt.return_none
		| Some r -> 
			let referrer = Model.Url.of_string r in
			DB.Insert.url_if_missing db_conn referrer >>= fun id ->
			Lwt.return_some @@ `Int id
	end >>= fun referrer_id ->

	let user_agent = Header.get headers "user-agent" in

	let ip = match Conduit_lwt_unix.endp_of_flow tcp_ch with
	| `TCP (ip, _) -> ip |> Ipaddr.to_string
	| _ -> "0.0.0.0" in

	let use = Model.Use.make
		~alias:(`Rec alias)
		~url:(`Ref alias.url)
		~referrer:referrer_id
		~user_agent
		~ip () in
	
	Lwt.catch
	(fun () -> DB.Insert.use db_conn use >>= fun _ -> Lwt.return_unit)
	(fun exn ->
		Lwt_io.printlf "Failed recording use: %s" (Core.Exn.to_string exn))

let handle_get_alias db_conn cache tcp_ch headers name =
	match Cache.get cache name with
	| Some payload -> 
		let alias = Cache.Payload.(Model.Alias.make
			~id:(alias_id payload) ~name ~url:(`Int (url_id payload)) ()) in
		ignore @@ record_use db_conn tcp_ch headers alias;

		let uri = Uri.of_string @@ Cache.Payload.url payload in
		C.Server.respond_redirect ~uri ()

	| None ->

	DB.Select.alias_by_name db_conn name >>= function
	| None | Some { status = Model.Alias.Status.Disabled } ->
		not_found_response ~alias:name ()
	| Some alias -> 

	url_by_alias db_conn alias >>= fun url -> 

	let alias' = { alias with url = Model.Url.URL url } in 
	ignore @@ record_use db_conn tcp_ch headers alias';

	let url' = Model.Url.to_string url in
	let alias_id = Option.value_exn (Model.Alias.id alias') in
	let url_id = Option.value_exn (Model.Url.id url) in
	let payload = Cache.Payload.make ~alias_id ~url_id ~url:url' in
	Cache.set cache name payload;

	let uri = Uri.of_string url' in
	C.Server.respond_redirect ~uri ()

let alias_of_path path = 
	let module S = Core.String in
	if S.length path > 0 && phys_equal path.[0] '/' then
		if phys_equal (S.length path) 1 then ""
		else S.sub path 1 (S.length path - 1) 
	else
		path

let router db_conn cache pathless_redirect_uri =
Cohttp.(fun (ch, conn) (req:Request.t) body ->
	let start = Unix.gettimeofday () in
	ignore @@ Lwt_io.printlf "Req: %s\n" req.resource;
	ignore @@ Lwt_io.printlf "%s\n" (req |> Request.headers |> Header.to_string);
	let alias = Request.uri req |> Uri.path |> alias_of_path in
	
	begin match req.meth, alias with
	| `GET, "" ->
		(match pathless_redirect_uri with
		| None -> not_found_response ()
		| Some uri -> C.Server.respond_redirect ~uri:(Uri.of_string uri) ())
	| `GET,  _ -> handle_get_alias db_conn cache ch (Request.headers req) alias
	|    _,  _ -> C.Server.respond_string ~status:`Method_not_allowed ~body:"" ()
	end >>= fun return ->

	let time_taken = Unix.gettimeofday () -. start in
	ignore @@ Lwt_io.printlf "Responded in %.8f seconds." time_taken;
	
	Lwt.return return
)

let main (conf:Conf.Alias_redirect.t) =
  let db = conf.database in
  DB.connect
    ~host:db.host ~user:db.user ~pass:db.pass ~db:db.database ()
    >>= DB.or_die "connect" >>= fun db_conn ->

	let cache = Cache.make
		~max_record_age:conf.cache.max_record_age
		~target_length:conf.cache.target_length
		~trim_length:conf.cache.trim_length in

	let mode = `TCP (`Port conf.port) in
	let callback = router db_conn cache conf.pathless_redirect_uri in
	let server = C.Server.make ~callback () in
	C.Server.create ~mode server >>= fun () ->

  DB.close db_conn

let start (conf:Conf.Alias_redirect.t) =
	Lwt_main.run @@ main conf
