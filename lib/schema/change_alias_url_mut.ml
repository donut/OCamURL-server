
open Graphql_lwt
open Lwt.Infix
open Printf

module DB = Lib_db
module Model = Lib_model

type input = {
  name: string;
  url: Model.Url.t;
  client_mutation_id: string;
}

type payload = {
  alias: Model.Alias.t;
  client_mutation_id: string;
}

type payload_or_error = {
  error: Error.t option;
  payload: payload option;
}

let input = Schema.Arg.(obj "ChangeAliasURLInput"
  ~coerce:(fun name url client_mutation_id ->
    { name; url; client_mutation_id; }    
  )
  ~fields:[
    arg "name" ~typ:(non_null string);
    arg "url" ~typ:(non_null (Url.input "ChangeAliasURLURLInput"));
    arg "clientMutationId" ~typ:(non_null string);
  ]
)

let payload db_conn = Schema.(obj "ChangeAliasURLPayload"
  ~fields:(fun payload -> [
    field "alias"
      ~args:Arg.[]
      ~typ:(non_null (Alias.alias db_conn))
      ~resolve:(fun () p -> p.alias)
    ;
    field "clientMutationId"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.client_mutation_id)
    ;
  ])
)

let payload_or_error db_conn = Error.make_x_or_error
	"ChangeAliasURLPayloadOrError"
  ~x_name:"payload" ~x_type:(payload db_conn)
  ~resolve_error:(fun () p -> p.error)
  ~resolve_x:(fun () p -> p.payload)

let resolver db_conn () () { name; url; client_mutation_id; } =
DB.(Model.(Error.(
  Lwt.catch (fun () -> 
    Select.alias_by_name db_conn name >>= function
    | None ->
      raise (E (Code.Bad_request,
								sprintf "The alias [%s] does not exist." name))
    | Some alias -> 

    Insert.url_if_missing db_conn url >>= fun url_id ->
		let current_url_id = Model.Url.(match alias.url with 
		| ID id 
		| URL { id = Some id } -> ID.to_int id
		| URL { id = None } -> -1
		) in

		match url_id == current_url_id with
		| true -> Lwt.return {
				error = None;
				payload = Some { alias; client_mutation_id; };
			}
		| false -> 

    Update.alias_url db_conn name url_id >>= fun () ->

    let url' = { url with id = Some (Url.ID.of_int url_id) } in
    let alias' = Alias.({ alias with url = Url.URL url' }) in

    Lwt.return {
			error = None;
			payload = Some { alias = alias'; client_mutation_id; };
		}
  )
  (fun exn -> 
    Lwt.return { error = Some (of_exn exn); payload = None; })
  )
))

let field db_conn = Schema.(io_field "changeAliasURL"
  ~typ:(non_null (payload_or_error db_conn))
  ~args:Arg.[
    arg "input" ~typ:(non_null input);
  ]
  ~resolve:(resolver db_conn)
)