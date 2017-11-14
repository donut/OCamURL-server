
open Graphql_lwt
open Lwt.Infix

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

let input = Schema.Arg.(obj "AddAliasInput"
  ~coerce:(fun name url client_mutation_id ->
    { name; url; client_mutation_id; }    
  )
  ~fields:[
    arg "name" ~typ:(non_null string);
    arg "url" ~typ:(non_null (Url.input "AddAliasURLInput"));
    arg "clientMutationId" ~typ:(non_null string);
  ]
)

let payload db_conn = Schema.(obj "AddAliasPayload"
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

let payload_or_error db_conn = Error.make_x_or_error "AddAliasPayloadOrError"
  ~x_name:"payload" ~x_type:(payload db_conn)
  ~resolve_error:(fun () p -> p.error)
  ~resolve_x:(fun () p -> p.payload)

let resolver db_conn () () { name; url; client_mutation_id; } =
DB.(Model.(Error.(
  Lwt.catch (fun () -> 
    Select.id_of_alias db_conn name >>= function
    | Some id -> Lwt.fail
      (E (Code.Bad_request, "The alias '" ^ name ^ "' already exists."))
    | None ->

    Insert.url_if_missing db_conn url >>= fun id ->
    let url' = { url with id = Some (Url.ID.of_int id) } in
    let alias = Alias.({
      name = Name.of_string name;
      url = Model.Url.URL url';
      status = Status.Enabled;
    }) in
    Insert.alias db_conn alias >>= fun () ->

    Lwt.return { error = None; payload = Some { alias; client_mutation_id; }; }
  )
  (fun exn -> 
    Lwt.return { error = Some (of_exn exn); payload = None; })
  )
))

let field db_conn = Schema.(io_field "addAlias"
  ~typ:(non_null (payload_or_error db_conn))
  ~args:Arg.[
    arg "input" ~typ:(non_null input);
  ]
  ~resolve:(resolver db_conn)
)
