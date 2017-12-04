
open Core
open Lwt.Infix
open Printf

module C = Cohttp_lwt_unix
module Cache = Lib.Cache
module Conf = Lib.Config
module DB = Lib.DB
module Model = Lib.Model

let not_found_response ?(body=None) ?(alias="") () = 
	let body = match body with
	| Some b -> b
	| None -> match alias with
		| "" -> "Page not found."
		| name -> sprintf "The alias [%s] does not exist." name in
	let headers = Cohttp.Header.add_opt None "content-type" "text/html" in
	C.Server.respond_string ~headers ~status:`Not_found ~body ()

let url_by_alias db_conn (alias:Model.Alias.t) = Model.(Url.(
	let exception Alias_missing_URL of string * int in
	match alias.url with
	| URL url -> Lwt.return url
	| ID id -> DB.Select.url_by_id db_conn (ID.to_int id) >>= function
		| None -> raise (Alias_missing_URL (Alias.Name.to_string alias.name,
																				ID.to_int id))
		| Some url -> Lwt.return url
))

let record_use db_connect tcp_ch headers ip_header (alias:Model.Alias.t) =
	let open Cohttp in 
	let module Opt = Core.Option in 

	begin match Header.get headers "referer" with
		| None -> Lwt.return_none
		| Some r -> 
			let referrer = Model.Url.of_string r in
			DB.Insert.url_if_missing db_connect referrer >>= fun id ->
			Lwt.return_some @@ `Int id
	end >>= fun referrer_id ->

	let user_agent = Header.get headers "user-agent" in

	let get_client_ip () = 
		match Conduit_lwt_unix.endp_of_flow tcp_ch with
		| `TCP (ip, _) -> ip |> Ipaddr.to_string
		| _ -> "0.0.0.0" in
	let ip = match ip_header with
		| None -> get_client_ip ()
		| Some h -> match Header.get headers h with
			| None -> get_client_ip ()
			| Some ip -> ip in

	let use = Model.Use.make
		~alias:(`Rec alias)
		~url:(`Ref alias.url)
		~referrer:referrer_id
		~user_agent
		~ip () in
	
	Lwt.catch
	(fun () ->
		DB.Insert.use db_connect use >>= fun _ -> Lwt.return_unit)
	(fun exn ->
		Lwt_io.printlf "Failed recording use: %s" (Core.Exn.to_string exn))

let handle_get_alias db_connect cache record_use name =
	match Cache.get cache name with
	| Some payload -> 
		let alias = Cache.Payload.(Model.Alias.make
			~id:(alias_id payload) ~name ~url:(`Int (url_id payload)) ()) in
		ignore @@ record_use alias;

		let uri = Uri.of_string @@ Cache.Payload.url payload in
		Lwt.return_some @@ C.Server.respond_redirect ~uri ()

	| None ->

	DB.Select.alias_by_name db_connect name >>= function
	| None | Some { status = Model.Alias.Status.Disabled } ->
		Lwt.return_none

	| Some alias -> 
	url_by_alias db_connect alias >>= fun url -> 

	let alias' = { alias with url = Model.Url.URL url } in 
	ignore @@ record_use alias';

	let url' = Model.Url.to_string url in
	let alias_id = Option.value_exn (Model.Alias.id alias') in
	let url_id = Option.value_exn (Model.Url.id url) in
	let payload = Cache.Payload.make ~alias_id ~url_id ~url:url' in
	Cache.set cache name payload;

	let uri = Uri.of_string url' in
	Lwt.return_some @@ C.Server.respond_redirect ~uri ()

let alias_of_path path = 
	let module S = Core.String in
	let path =
		if S.length path > 0 && path.[0] = '/' then
			if (S.length path) = 1 then ""
			else S.sub path 1 (S.length path - 1) 
		else
			path in
	Uri.pct_decode path

let router ~db_connect ~cache
           ~pathless_redirect_uri ~page_404 ~page_50x ~ip_header
= Cohttp.(fun (ch, conn) (req:Request.t) body ->
	Lwt.catch 
	(fun () -> 
		let start = Unix.gettimeofday () in
		ignore @@ Lwt_io.printlf "Req: %s\n" req.resource;
		ignore @@ Lwt_io.printlf "%s\n" (req |> Request.headers |> Header.to_string);
		let alias = Request.uri req |> Uri.path |> alias_of_path in
		
		begin match req.meth, alias with
		| `GET, "" ->
			(match pathless_redirect_uri with
			| None -> not_found_response ()
			| Some uri -> C.Server.respond_redirect ~uri:(Uri.of_string uri) ())

		| `GET, _ ->
			let headers = (Request.headers req) in
			let record_use = record_use db_connect ch headers ip_header in
			handle_get_alias db_connect cache (record_use) alias >>= begin function
			| Some response -> response
			| None -> not_found_response ~body:page_404 ~alias ()
			end

		|  _, _ ->
			C.Server.respond_string ~status:`Method_not_allowed ~body:"" ()
		end >>= fun return ->

		let time_taken = Unix.gettimeofday () -. start in
		ignore @@ Lwt_io.printlf "Responded in %.8f seconds." time_taken;

		Lwt.return return
	)
	(fun exn -> 
		match page_50x with
		| None -> raise exn
		| Some body ->
			let headers = Cohttp.Header.add_opt None "content-type" "text/html" in
			C.Server.respond_string ~headers ~status:`Internal_server_error ~body ()
	)
)

let main (conf:Conf.Alias_redirect.t) =
  let db = conf.database in
  let db_connect = DB.make_connect_func
		~host:db.host ~user:db.user ~pass:db.pass ~db:db.database () in
	let cache = Cache.make
		~max_record_age:conf.cache.max_record_age
		~target_length:conf.cache.target_length
		~trim_length:conf.cache.trim_length in

	let mode = `TCP (`Port conf.port) in
	let callback = router
		~db_connect ~cache
		~pathless_redirect_uri:conf.pathless_redirect_uri
		~page_404:(Option.map conf.error_404_page_path In_channel.read_all)
		~page_50x:(Option.map conf.error_50x_page_path In_channel.read_all)
		~ip_header:conf.ip_header in
	let server = C.Server.make ~callback () in
	C.Server.create ~mode server >>= fun () ->

  DB.final_close ();
	Lwt.return_unit

let start (conf:Conf.Alias_redirect.t) =
	Lwt_main.run @@ main conf
