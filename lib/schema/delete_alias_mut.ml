
open Graphql_lwt
open Lwt.Infix
open Printf

module DB = Lib_db
module Model = Lib_model

type input = {
  name: string;
	disable_if_used: bool;
  client_mutation_id: string;
}

type action = Delete | Disable

type payload = {
  action_taken: action;
  client_mutation_id: string;
}

type payload_or_error = {
  error: Error.t option;
  payload: payload option;
}

let input = Schema.Arg.(obj "DeleteAliasInput"
  ~coerce:(fun name disable_if_used client_mutation_id ->
    { name; disable_if_used; client_mutation_id; }    
  )
  ~fields:[
    arg  "name" ~typ:(non_null string);
		arg' "disableIfUsed" ~typ:bool ~default:false;
    arg  "clientMutationId" ~typ:(non_null string);
  ]
)

let action = Schema.(enum "DeleteAliasAction" ~values:[
	enum_value "delete" ~value:Delete;
	enum_value "disable" ~value:Disable;
])

let payload db_conn = Schema.(obj "DeleteAliasPayload"
  ~fields:(fun payload -> [
    field "actionTaken"
      ~args:Arg.[]
      ~typ:(non_null action)
      ~resolve:(fun () p -> p.action_taken)
    ;
    field "clientMutationId"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.client_mutation_id)
    ;
  ])
)

let payload_or_error db_conn = Error.make_x_or_error
	"DeleteAliasPayloadOrError"
  ~x_name:"payload" ~x_type:(payload db_conn)
  ~resolve_error:(fun () p -> p.error)
  ~resolve_x:(fun () p -> p.payload)

let resolver db_conn () () { name; disable_if_used; client_mutation_id; } =
DB.(Model.(Error.(
  Lwt.catch
	(fun () -> 
    Select.id_of_alias db_conn name >>= function
    | None ->
      raise (E (Code.Bad_request,
								sprintf "The alias '%s' does not exist." name))
    | Some _ -> 

		Select.use_count_of_alias db_conn name >>= (function
			| 0 -> 
				Delete.alias db_conn name >>= fun () ->
				Lwt.return Delete
			| _ -> match disable_if_used with 
				| false ->
					raise (E (Code.Bad_request,
									  sprintf "The alias [%s] has already been used so cannot be deleted. Pass `disableIfUsed: true` to disable instead." name))
				| true ->
					Update.alias_status db_conn name Model.Alias.Status.Disabled
					>>= fun () -> Lwt.return Disable
		) >>= fun action_taken ->

    Lwt.return {
			error = None;
			payload = Some { action_taken; client_mutation_id; };
		}
  )
  (fun exn -> 
    Lwt.return { error = Some (of_exn exn); payload = None; })
  )
))

let field db_conn = Schema.(io_field "deleteAlias"
  ~typ:(non_null (payload_or_error db_conn))
  ~args:Arg.[
    arg "input" ~typ:(non_null input);
  ]
  ~resolve:(resolver db_conn)
)
