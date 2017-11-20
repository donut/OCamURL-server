
open Graphql_lwt
open Lwt.Infix
open Printf

module DB = Lib_db
module Model = Lib_model

type input = {
  name: string;
	new_name: string;
	disable_and_add_if_used: bool;
  client_mutation_id: string;
}

type action = Rename | Disable_and_add

type payload = {
  action_taken: action;
  client_mutation_id: string;
}

type payload_or_error = {
  error: Error.t option;
  payload: payload option;
}

let input = Schema.Arg.(obj "RenameAliasInput"
  ~coerce:(fun name new_name disable_and_add_if_used client_mutation_id ->
    { name; new_name; disable_and_add_if_used; client_mutation_id; }    
  )
  ~fields:[
    arg  "name" ~typ:(non_null string);
    arg  "newName" ~typ:(non_null string);
		arg' "disableAndAddIfUsed" ~typ:bool ~default:false;
    arg  "clientMutationId" ~typ:(non_null string);
  ]
)

let action = Schema.(enum "RenameAliasAction" ~values:[
	enum_value "RENAME" ~value:Rename;
	enum_value "DISABLE_AND_ADD" ~value:Disable_and_add;
])

let payload db_conn = Schema.(obj "RenameAliasPayload"
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
	"RenameAliasPayloadOrError"
  ~x_name:"payload" ~x_type:(payload db_conn)
  ~resolve_error:(fun () p -> p.error)
  ~resolve_x:(fun () p -> p.payload)

let resolver db_conn () ()
	{ name; new_name; disable_and_add_if_used; client_mutation_id; } =
DB.(Model.(Error.(
  Lwt.catch
	(fun () -> 
    Select.alias_by_name db_conn name >>= function
    | None ->
      raise (E (Code.Bad_request,
								sprintf "The alias [%s] does not exist." name))
    | Some alias -> 

		if new_name == name
		then raise (E (Code.Bad_request,
									 "`newName` must be different than the current name."))
		else

		Select.id_of_alias db_conn new_name >>= function
		| Some _ ->
			raise (E (Code.Bad_request,
								sprintf "The alias [%s] already exists." new_name))
		| None ->

		Select.use_count_of_alias db_conn name >>= (function
			| 0 -> 
				Update.alias_name db_conn name new_name >>= fun () ->
				Lwt.return Rename
			| _ -> match disable_and_add_if_used with 
				| false ->
					raise (E (Code.Bad_request,
									  sprintf "The alias [%s] has already been used so cannot be renamed. Pass `disableAndAddIfUsed: true` to disable the old alias and create a new one with the new name." name))
				| true ->
					Update.alias_status db_conn name Model.Alias.Status.Disabled
					>>= fun () ->
					let alias' = Model.Alias.({
            id = None;
						name = Name.of_string new_name;
						url = alias.url;
						status = Status.Enabled;
					}) in 
					Insert.alias db_conn alias' >>= fun () ->
					Lwt.return Disable_and_add
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

let field db_conn = Schema.(io_field "renameAlias"
  ~typ:(non_null (payload_or_error db_conn))
  ~args:Arg.[
    arg "input" ~typ:(non_null input);
  ]
  ~resolve:(resolver db_conn)
)
