
open Graphql_lwt
open Lwt.Infix
open Printf

module DB = Lib_db
module Model = Lib_model

type input = {
	name: string;
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

let input = Schema.Arg.(obj "EnableAliasInput"
  ~coerce:(fun name client_mutation_id ->
    { name; client_mutation_id; }    
  )
  ~fields:[
    arg "name" ~typ:(non_null string);
    arg "clientMutationId" ~typ:(non_null string);
  ]
)

let payload db_conn = Schema.(obj "EnableAliasPayload"
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

let payload_or_error db_conn = Error.make_x_or_error "EnableAliasPayloadOrError"
  ~x_name:"payload" ~x_type:(payload db_conn)
  ~resolve_error:(fun () p -> p.error)
  ~resolve_x:(fun () p -> p.payload)

let resolver db_conn () () { name; client_mutation_id; } = DB.(Model.(Error.(
	Lwt.catch
	(fun () ->
		Update.alias_status db_conn name Alias.Status.Enabled >>= fun () ->
		Select.alias_by_name db_conn name >>= function
		| None -> Lwt.return {
				error = Some {
					code = Code.Bad_request;
					message = sprintf "The passed alias '%s' doesn't exist." name;
				};
				payload = None;
			}
		| Some alias -> Lwt.return {
				error = None;
				payload = Some { alias; client_mutation_id; }
			}
	)
	(fun exn ->
		Lwt.return { error = Some (of_exn exn); payload = None; }
	)
)))

let field db_conn = Schema.(io_field "enableAlias"
  ~typ:(non_null (payload_or_error db_conn))
  ~args:Arg.[
    arg "input" ~typ:(non_null input);
  ]
  ~resolve:(resolver db_conn)
)
