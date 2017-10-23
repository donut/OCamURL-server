
open Graphql_lwt

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

let input = Schema.Arg.(obj "PutAliasInput"
  ~coerce:(fun name url client_mutation_id ->
    { name; url; client_mutation_id; }    
  )
  ~fields:[
    arg "name" ~typ:(non_null string);
    arg "url" ~typ:(non_null (Url.input "PutAliasURLInput"));
    arg "clientMutationId" ~typ:(non_null string);
  ]
)

let payload = Schema.(obj "PutAliasPayload"
  ~fields:(fun payload -> [
    field "alias"
      ~args:Arg.[]
      ~typ:(non_null Alias.alias)
      ~resolve:(fun () p -> p.alias)
    ;
    field "clientMutationId"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.client_mutation_id)
    ;
  ])
)

let payload_or_error = Error.make_x_or_error "PutAliasPayloadOrError"
  ~x_name:"payload" ~x_type:payload
  ~resolve_error:(fun () p -> p.error)
  ~resolve_x:(fun () p -> p.payload)

let resolver db_connection = fun () () { name; url; client_mutation_id; }
-> DB.(Model.(Error.(
  try (
    match Select.id_of_alias db_connection name with
      | Some id ->
        raise (E (Code.Bad_request, "The alias '" ^ name ^ "' already exists."))
      | None -> ();

    let id_of = Select.id_of_url db_connection in
    let url_id = match id_of url with
      | Some id -> id
      | None ->  
        Insert.url db_connection url;
        match id_of url with 
        | Some id -> id
        | None -> raise (E (Code.Internal_server_error, "Despite inserting the passed URL, it could not be found in the database."))
    in

    let url' = { url with id = Some (Url.ID.of_int url_id) } in
    let alias = Alias.({ name = Name.of_string name; url = url' }) in
    Insert.alias db_connection alias;

    { error = None; payload = Some { alias; client_mutation_id; }; }
  )
  with e -> { error = Some (of_exception e); payload = None; }
)))

let field db_connection = Schema.(field "putAlias"
  ~typ:(non_null payload_or_error)
  ~args:Arg.[
    arg "input" ~typ:(non_null input);
  ]
  ~resolve:(resolver db_connection)
)
