
open Core
open Str

open Lwt

open Ext_list
open Model
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
  Gql.Schema.Arg.(enum "URLSchemeInput" ~values:Schema.Url.scheme_values)


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
      ~typ:(non_null Schema.Alias.alias)
      ~resolve:(fun () p -> p.alias)
    ;
    field "clientMutationId"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.client_mutation_id)
    ;
  ])
)

let print_row row =
  let module M = Mariadb.Blocking in
  printf "---\n%!";
  M.Row.StringMap.iter
    (fun name field ->
      printf "%20s " name;
      match M.Field.value field with
      | `Int i -> printf "%d\n%!" i
      | `Float x -> printf "%f\n%!" x
      | `String s -> printf "%s\n%!" s
      | `Bytes b -> printf "%s\n%!" "Bytes! :)"
      | `Time t ->
          printf "%04d-%02d-%02d %02d:%02d:%02d\n%!"
            (M.Time.year t)
          (M.Time.month t)
          (M.Time.day t)
          (M.Time.hour t)
          (M.Time.minute t)
          (M.Time.second t)
    | `Null -> printf "NULL\n%!")
  row

let stream res =
  let module M = Mariadb.Blocking in
  let module F = struct exception E of M.error end in
  let next _ =
    match M.Res.fetch (module M.Row.Map) res with
    | Ok (Some _ as row) -> row
    | Ok None -> None
    | Error e -> raise (F.E e) in
  try Ok (Stream.from next)
  with F.E e -> Error e

let schema = Gql.Schema.(schema [
    field "url"
      ~args:Arg.[
        arg "alias" ~typ:(non_null string);
      ]
      ~typ:Schema.Url.url
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

        let module M = Mariadb.Blocking in
        let or_die where = function
          | Ok x -> x
          | Error (num, msg) -> failwith @@ sprintf "%s #%d: %s" where num msg 
        in
        let mariadb = M.connect
          ~host:"localhost"
          ~user:"root"
          ~pass:""
          ~db:"rtmDOTtv" () |> or_die "connect" in
        let query = "INSERT INTO url SET scheme = ?, host = ?, path = ?" in
        let stmt = M.prepare mariadb query |> or_die "prepare" in
        let res = M.Stmt.execute stmt Url.([|
          `String (Scheme.to_string url'.scheme);
          `String (Host.to_string url'.host);
          `String (Path.to_string url'.path);
        |]) |> or_die "execute" in
        begin match res with
        | Some res ->
          printf "#rows: %d\n%!" (M.Res.num_rows res);
          let s = stream res |> or_die "stream" in
          Stream.iter print_row s
        | None -> ()
        end;
        M.Stmt.close stmt |> or_die "close statement";
        M.close mariadb;

        let alias = Alias.({ name = Name.of_string name; url = url' }) in
        aliases := append !aliases [alias];
        { alias; client_mutation_id; }
      )
  ]
)

let () =
  Gql.Server.start ~ctx:(fun () -> ()) schema |> Lwt_main.run  