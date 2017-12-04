
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

let payload db_handle = Schema.(obj "AddAliasPayload"
  ~fields:(fun payload -> [
    field "alias"
      ~args:Arg.[]
      ~typ:(non_null (Alias.alias db_handle))
      ~resolve:(fun () p -> p.alias)
    ;
    field "clientMutationId"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.client_mutation_id)
    ;
  ])
)

let payload_or_error db_handle = Error.make_x_or_error "AddAliasPayloadOrError"
  ~x_name:"payload" ~x_type:(payload db_handle)
  ~resolve_error:(fun () p -> p.error)
  ~resolve_x:(fun () p -> p.payload)

let resolver ~db_handle ~reserved () () { name; url; client_mutation_id; } =
  Lwt.catch (fun () -> 
    Alias.is_available_exn ~db_handle ~reserved name >>= fun () ->

    DB.Insert.url_if_missing db_handle url >>= fun id ->
    let url' = Model.Url.set_id url id in
    let alias = Model.Alias.make ~name ~url:(`Rec url') () in
    DB.Insert.alias db_handle alias >>= fun id ->

    let alias' = Model.Alias.set_id alias id in
    Lwt.return { 
      error = None;
      payload = Some { alias = alias'; client_mutation_id; };
    }
  )
  (fun exn -> Error.(
    Lwt.return { error = Some (of_exn exn); payload = None; }
  ))

let field ~db_handle ~reserved = Schema.(io_field "addAlias"
  ~typ:(non_null (payload_or_error db_handle))
  ~args:Arg.[
    arg "input" ~typ:(non_null input);
  ]
  ~resolve:(resolver ~db_handle ~reserved)
)
