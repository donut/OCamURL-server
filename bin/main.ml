
open Core
open Str

open Lwt

open Lib.Common.Ext_list
open Lib.Model
open Printf

module Gql = Graphql_lwt

let urls = Url.(ref [
  {
    id = Some (ID.of_int 1);
    scheme = HTTP;
    user = None; password = None;
    host = Host.of_string "www.rtm.tv";
    port = Some (Port.of_int 123);
    path = Path.of_string "/";
    params = None; fragment = None;
  };
  {
    id = Some (ID.of_int 2);
    scheme = HTTPS;
    user = None; password = None;
    host = Host.of_string "feeds.rtm.tv"; port = None;
    path = Path.of_string "/";
    params = None; fragment = None;
  };
  {
    id = Some (ID.of_int 3);
    scheme = HTTPS;
    user = None; password = None;
    host = Host.of_string "www.rightthisminute.com"; port = None;
    path = Path.of_string "/search/site/perhaps";
    params = Some (Params.of_list [
      { key = "raining"; value = Some "outside"; }
    ]);
    fragment = Some (Fragment.of_string "main-content");
  };
])

let aliases = Alias.(ref [
  { name = Name.of_string "coffee"; url = nth !urls 0 };
  { name = Name.of_string "nugget"; url = nth !urls 1 };
  { name = Name.of_string "owl";    url = nth !urls 2 };
])

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

let schema db_connection = Gql.Schema.(schema [
    field "url"
      ~args:Arg.[
        arg "alias" ~typ:(non_null string);
      ]
      ~typ:Lib.Schema.Url.url
      ~resolve:(fun () () name -> Alias.(
        let compare (alias:t) = (Name.to_string alias.name) = name in
        let alias = find_opt (compare) !aliases in
        Option.map alias (fun a -> a.url)
      ))
  ]
  ~mutations:[
    field "putAlias"
      ~typ:(non_null put_alias_payload)
      ~args:Arg.[
        arg "input" ~typ:(non_null put_alias_input);
      ]
      ~resolve:(fun () () { name; url; client_mutation_id; } ->
        let id = match (last_opt !urls) with
          | None | Some { id = None } -> 1
          | Some { id = Some id } -> (Url.ID.to_int id) + 1
        in
        let url' = { url with id = Some (Url.ID.of_int id) } in

        urls := append !urls [url'];

        let _ = Lib.DB.Select.id_of_url db_connection url' in
        Lib.DB.Insert.url db_connection url';

        let alias = Alias.({ name = Name.of_string name; url = url' }) in
        aliases := append !aliases [alias];
        { alias; client_mutation_id; }
      )
  ]
)

let () =
  let connection = Lib.DB.connect
    ~host:"localhost" ~user:"root" ~pass:"" ~db:"rtmDOTtv" ()
    |> Lib.DB.or_die "connect"
  in

  let url = Url.({
    id = None;
    scheme = HTTP;
    user = Some (Username.of_string "bombs");
    password = Some (Password.of_string "pow");
    host = Host.of_string "www.rightthisminute.com"; port = None;
    path = Path.of_string "/search/site/perhaps";
    params = Some (Params.of_list [
      { key = "raining"; value = Some "outside"; }
    ]);
    fragment = Some (Fragment.of_string "main-content");
  }) in

  let exception ID_of_inserted_URL_missing in

  let id_of = Lib.DB.Select.id_of_url connection in
  let url_id = match id_of url with
    | Some id -> id
    | None -> 
      Lib.DB.Insert.url connection url;
      match id_of url with 
      | Some id -> id
      | None -> raise ID_of_inserted_URL_missing
  in

  printf "id of url: %d\n" url_id;
  (* Gql.Server.start ~ctx:(fun () -> ()) (schema connection) |> Lwt_main.run; *)

  Lib.DB.close connection;