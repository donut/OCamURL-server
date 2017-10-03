
open Lwt
open Str
open List

open Graphql_lwt

let rec last = function
  | [] -> raise Not_found
  | [element] -> element
  | _ :: remainder -> last remainder

let last_opt list = 
  try Some (last list) with
    | Not_found -> None

type scheme = HTTP | HTTPS
let string_of_scheme = function | HTTP -> "http" | HTTPS -> "https"
type url_param = { key: string; value: string option; }

type url = {
  id: int option;
  scheme: scheme;
  user: string option;
  password: string option;
  host: string;
  port: int option;
  path: string;
  params: url_param list option;
  fragment: string option;
}

type alias = {
  name: string;
  url: url;
}

type use = {
  id: int;
  alias: alias;
  url: url;
  referer: url option;
  user_agent: string option;
  ip: string;
  timestamp: int;
}

type put_alias_input = {
  name: string;
  url: url;
  client_mutation_id: string;
}

type put_alias_payload = {
  alias: alias;
  client_mutation_id: string;
}

let urls = ref [
  {
    id = Some 1;
    scheme = HTTP;
    user = None; password = None;
    host = "www.rtm.tv"; port = Some 123;
    path = "/"; params = None; fragment = None;
  };
  {
    id = Some 2;
    scheme = HTTPS;
    user = None; password = None;
    host = "feeds.rtm.tv"; port = None;
    path = "/"; params = None; fragment = None;
  };
  {
    id = Some 3;
    scheme = HTTPS;
    user = None; password = None;
    host = "www.rightthisminute.com"; port = None;
    path = "/search/site/perhaps"; params = Some [
      { key = "raining"; value = Some "outside"; }
    ];
    fragment = Some "main-content";
  };
]

let aliases = ref [
  { name = "coffee"; url = nth !urls 0 };
  { name = "nugget"; url = nth !urls 1 };
  { name = "owl";    url = nth !urls 2 };
]

let url_scheme_values = Schema.([
    enum_value "http" ~value:HTTP;
    enum_value "https" ~value:HTTPS;
])
let url_scheme =
  Schema.(enum "URLScheme" ~values:url_scheme_values)
let url_scheme_input =
  Schema.Arg.(enum "URLSchemeInput" ~values:url_scheme_values)

let url_param = Schema.(obj "URLParam"
  ~fields:(fun url_param -> [
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
  ])
)

let url = Schema.(obj "URL"
  ~fields:(fun url -> [
    field "id"
      ~args:Arg.[]
      ~typ:(non_null guid)
      ~resolve:(fun () (p:url) ->
        match p.id with | None -> "ERROR" | Some id -> string_of_int id 
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
      ~resolve:(fun () p -> p.user)
    ;
    field "password"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> p.password)
    ;
    field "host"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.host)
    ;
    field "port"
      ~args:Arg.[]
      ~typ:int
      ~resolve:(fun () p -> p.port)
    ;
    field "path"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.path)
    ;
    field "params"
      ~args:Arg.[]
      ~typ:(list (non_null url_param))
      ~resolve:(fun () p -> p.params)
    ;
    field "fragment"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> p.fragment)
    ;
  ])
)


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
  ~coerce:(fun key value -> { key; value; })
  ~fields:[
    arg "key" ~typ:(non_null string);
    arg "value" ~typ:string;
  ])

let url_input = Schema.Arg.(obj "URLInput"
  ~coerce:(fun scheme user password host port path params fragment ->
    { id = None; scheme; user; password; host; port; path; params; fragment }
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
          | Some { id = Some id } -> id + 1
        in
        let url' = { url with id = Some id } in
        urls := append !urls [url'];
        let alias = { name; url = url' } in
        aliases := append !aliases [alias];
        { alias; client_mutation_id; }
      )
  ]
)

let () =
  Server.start ~ctx:(fun () -> ()) schema |> Lwt_main.run  