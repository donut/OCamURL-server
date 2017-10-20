
open Core
open Str

open Lwt

open Lib.Common.Ext_list
open Lib.Model

module Gql = Graphql_lwt


let url_scheme_input =
  Gql.Schema.Arg.(enum "URLSchemeInput" ~values:Lib.Schema.Url.scheme_values)


type put_alias_input = {
  name: string;
  url: Url.t;
  client_mutation_id: string;
}

type put_alias_payload = {
  alias: Alias.t;
  client_mutation_id: string;
}

type put_alias_payload_or_error = {
  error: Lib.Schema.Error.t option;
  payload: put_alias_payload option;
}

let url_param_input = Gql.Schema.Arg.(obj "URLParamInput"
  ~coerce:(fun key value -> Url.({ key; value; }))
  ~fields:[
    arg "key" ~typ:(non_null string);
    arg "value" ~typ:string;
  ])

let url_input = Gql.Schema.Arg.(obj "URLInput"
  ~coerce:(fun scheme user password host port path params fragment ->
    Url.({
      id = None;
      scheme;
      user = Option.map user Username.of_string;
      password = Option.map password Password.of_string;
      host = Host.of_string host;
      port = Option.map port Port.of_int;
      path = Path.of_string path;
      params = Option.map params Params.of_list;
      fragment = Option.map fragment Fragment.of_string;
    })
  )
  ~fields:[
    arg  "scheme" ~typ:(non_null url_scheme_input);
    arg  "user" ~typ:string;
    arg  "password" ~typ:string;
    arg  "host" ~typ:(non_null string);
    arg  "port" ~typ:int;
    arg' "path" ~typ:string ~default:"";
    arg  "params" ~typ:(list (non_null url_param_input));
    arg  "fragment" ~typ:string;
])

let put_alias_input = Gql.Schema.Arg.(obj "PutAliasInput"
  ~coerce:(fun name url client_mutation_id ->
    { name; url; client_mutation_id; }    
  )
  ~fields:[
    arg "name" ~typ:(non_null string);
    arg "url" ~typ:(non_null url_input);
    arg "clientMutationId" ~typ:(non_null string);
  ]
)

let put_alias_payload = Gql.Schema.(obj "PutAliasPayload"
  ~fields:(fun payload -> [
    field "alias"
      ~args:Arg.[]
      ~typ:(non_null Lib.Schema.Alias.alias)
      ~resolve:(fun () p -> p.alias)
    ;
    field "clientMutationId"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.client_mutation_id)
    ;
  ])
)

let put_alias_payload_or_error = Gql.Schema.(Lib.Schema.(
  obj "PutAliasPayloadOrError"
  ~fields:(fun put_alias_payload_or_error -> [
    field "error"
      ~args:Arg.[]
      ~typ:Lib.Schema.Error.error
      ~resolve:(fun () p -> p.error)
    ;
    field "payload"
      ~args:Arg.[]
      ~typ:put_alias_payload
      ~resolve:(fun () p -> p.payload)
    ;
  ])

))

let schema db_connection = Gql.Schema.(schema [
    field "url"
      ~args:Arg.[
        arg "alias" ~typ:(non_null string);
      ]
      ~typ:Lib.Schema.Url.url
      ~resolve:(fun () () name -> 
        Lib.DB.Select.url_of_alias db_connection name
      )
  ]
  ~mutations:[
    field "putAlias"
      ~typ:(non_null put_alias_payload_or_error)
      ~args:Arg.[
        arg "input" ~typ:(non_null put_alias_input);
      ]
      ~resolve:(fun () () { name; url; client_mutation_id; } -> Lib.(DB.(Model.(
        let exception Alias_already_exists of string in
        let exception ID_of_inserted_URL_missing in

        try (
          match Select.id_of_alias db_connection name with
            | Some id ->
              raise (Alias_already_exists (name ^ ":" ^ (string_of_int id)))
            | None -> ();

          let id_of = Select.id_of_url db_connection in
          let url_id = match id_of url with
            | Some id -> id
            | None ->  
              Insert.url db_connection url;
              match id_of url with 
              | Some id -> id
              | None -> raise ID_of_inserted_URL_missing
          in

          let url' = { url with id = Some (Url.ID.of_int url_id) } in
          let alias = Alias.({ name = Name.of_string name; url = url' }) in
          Insert.alias db_connection alias;

          { error = None; payload = Some { alias; client_mutation_id; }; }
        )
        with
          | Alias_already_exists s -> { error = Some {
            code = 1;
            message = "The alias already exists: " ^ s;
          }; payload = None; }
          | ID_of_inserted_URL_missing -> { error = Some {
            code = 2;
            message = "Despite inserting the passed URL, it could not be found."
          }; payload = None; }
          | e -> { error = Some {
            code = 3;
            message = "An unknown error occurred: " ^ (Exn.to_string e);
          }; payload = None; }
      ))))
  ]
)

let () =
  let connection = Lib.DB.connect
    ~host:"localhost" ~user:"root" ~pass:"" ~db:"rtmDOTtv" ()
    |> Lib.DB.or_die "connect"
  in

  Gql.Server.start ~ctx:(fun () -> ()) (schema connection) |> Lwt_main.run;

  Lib.DB.close connection;