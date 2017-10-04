
open Core
open Str

open Lwt
open Graphql_lwt

open Ext_list
open Model

type alias = {
  name: string;
  url: Url.t;
}

type use = {
  id: int;
  alias: alias;
  url: Url.t;
  referer: Url.t option;
  user_agent: string option;
  ip: string;
  timestamp: int;
}

type put_alias_input = {
  name: string;
  url: Url.t;
  client_mutation_id: string;
}

type put_alias_payload = {
  alias: alias;
  client_mutation_id: string;
}

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

let aliases = ref [
  { name = "coffee"; url = nth !urls 0 };
  { name = "nugget"; url = nth !urls 1 };
  { name = "owl";    url = nth !urls 2 };
]

let url_scheme_values = Url.Scheme.(Schema.([
    enum_value "http" ~value:HTTP;
    enum_value "https" ~value:HTTPS;
]))
let url_scheme =
  Schema.(enum "URLScheme" ~values:url_scheme_values)
let url_scheme_input =
  Schema.Arg.(enum "URLSchemeInput" ~values:url_scheme_values)

let url_param = Url.(Schema.(obj "URLParam"
  ~fields:(fun param -> [
    field "key"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.key)
    ;
    field "value"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> p.value)
    ;
  ]))
)

let url = Url.(Schema.(obj "URL"
  ~fields:(fun url -> [
    field "id"
      ~args:Arg.[]
      ~typ:(non_null guid)
      ~resolve:(fun () (p:t) -> match p.id with 
        | None -> "ERROR"
        | Some id -> id |> ID.to_int |> string_of_int
      )
    ;
    field "scheme"
      ~args:Arg.[]
      ~typ:(non_null url_scheme)
      ~resolve:(fun () p -> p.scheme)
    ;
    field "user"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> Option.map p.user Username.to_string)
    ;
    field "password"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> Option.map p.password Password.to_string)
    ;
    field "host"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> Host.to_string p.host)
    ;
    field "port"
      ~args:Arg.[]
      ~typ:int
      ~resolve:(fun () p -> Option.map p.port Port.to_int)
    ;
    field "path"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> Path.to_string p.path)
    ;
    field "params"
      ~args:Arg.[]
      ~typ:(list (non_null url_param))
      ~resolve:(fun () p -> Option.map p.params Params.to_list)
    ;
    field "fragment"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> Option.map p.fragment Fragment.to_string)
    ;
  ])
))


let alias = Schema.(obj "Alias"
  ~fields:(fun alias -> [
    field "id"
      ~args:Arg.[]
      ~typ:(non_null guid)
      ~resolve:(fun () (p:alias) -> p.name)
    ;
    field "name"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () (p:alias) -> p.name)
    ;
    field "url"
      ~args:Arg.[]
      ~typ:(non_null url)
      ~resolve:(fun () (p:alias) -> p.url)
    ;
  ])
)

let use = Schema.(obj "Use"
  ~fields:(fun use -> [
    field "id"
      ~args:Arg.[]
      ~typ:(non_null guid)
      ~resolve:(fun () p -> string_of_int p.id)
    ;
    field "alias"
      ~args:Arg.[]
      ~typ:(non_null alias)
      ~resolve:(fun () (p:use) -> p.alias)
    ;
    field "url"
      ~args:Arg.[]
      ~typ:(non_null url)
      ~resolve:(fun () (p:use) -> p.url)
    ;
    field "referer"
      ~args:Arg.[]
      ~typ:url
      ~resolve:(fun () p -> p.referer)
    ;
    field "user_agent"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> p.user_agent)
    ;
    field "ip"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.ip)
    ;
    field "timestamp"
      ~args:Arg.[]
      ~typ:(non_null int)
      ~resolve:(fun () p -> p.timestamp)
    ;
  ])
)

let url_param_input = Schema.Arg.(obj "URLParamInput"
  ~coerce:(fun key value -> Url.({ key; value; }))
  ~fields:[
    arg "key" ~typ:(non_null string);
    arg "value" ~typ:string;
  ])

let url_input = Schema.Arg.(obj "URLInput"
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

let put_alias_input = Schema.Arg.(obj "PutAliasInput"
  ~coerce:(fun name url client_mutation_id ->
    { name; url; client_mutation_id; }    
  )
  ~fields:[
    arg "name" ~typ:(non_null string);
    arg "url" ~typ:(non_null url_input);
    arg "clientMutationId" ~typ:(non_null string);
  ]
)

let put_alias_payload = Schema.(obj "PutAliasPayload"
  ~fields:(fun payload -> [
    field "alias"
      ~args:Arg.[]
      ~typ:(non_null alias)
      ~resolve:(fun () p -> p.alias)
    ;
    field "clientMutationId"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.client_mutation_id)
    ;
  ])
)


let schema = Schema.(schema [
    field "url"
      ~args:Arg.[
        arg "alias" ~typ:(non_null string);
      ]
      ~typ:url
      ~resolve:(fun () () name ->
        let compare (alias:alias) = alias.name = name in
        let alias = find_opt (compare) !aliases in
        match alias with
          None -> None | Some alias -> Some alias.url
      )
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
        let alias = { name; url = url' } in
        aliases := append !aliases [alias];
        { alias; client_mutation_id; }
      )
  ]
)

let () =
  Server.start ~ctx:(fun () -> ()) schema |> Lwt_main.run  