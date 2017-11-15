
open Graphql_lwt
open Lwt.Infix

module DB = Lib_db
module Model = Lib_model
module Opt = Core.Option

let scheme_values = Model.Url.Scheme.(Schema.([
    enum_value "HTTP" ~value:HTTP;
    enum_value "HTTPS" ~value:HTTPS;
]))

let scheme = Schema.(enum "URLScheme" ~values:scheme_values)
let scheme_input = Schema.Arg.(enum "URLSchemeInput" ~values:scheme_values)

let param = Model.Url.(Schema.(obj "URLParam"
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

let param_input = Schema.Arg.(obj "URLParamInput"
  ~coerce:(fun key value -> Model.Url.({ key; value; }))
  ~fields:[
    arg "key" ~typ:(non_null string);
    arg "value" ~typ:string;
  ])

let url = Model.Url.(Schema.(obj "URL"
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
      ~typ:(non_null scheme)
      ~resolve:(fun () p -> p.scheme)
    ;
    field "user"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> Opt.map p.user Username.to_string)
    ;
    field "password"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> Opt.map p.password Password.to_string)
    ;
    field "host"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> Host.to_string p.host)
    ;
    field "port"
      ~args:Arg.[]
      ~typ:int
      ~resolve:(fun () p -> Opt.map p.port Port.to_int)
    ;
    field "path"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> Path.to_string p.path)
    ;
    field "params"
      ~args:Arg.[]
      ~typ:(list (non_null param))
      ~resolve:(fun () p -> Opt.map p.params Params.to_list)
    ;
    field "fragment"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> Opt.map p.fragment Fragment.to_string)
    ;
    field "asString"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> to_string p)
    ;
  ])
))

type or_error = {
  error: Error.t option;
  url: Model.Url.t option;
}

let or_error = Error.make_x_or_error "URLOrError"
  ~x_name:"url" ~x_type:url
  ~resolve_error:(fun () p -> p.error)
  ~resolve_x:(fun () p -> p.url)

let input name = Schema.Arg.(obj name
  ~coerce:(fun scheme user password host port path params fragment ->
    Model.Url.(Core.Option.({
      id = None;
      scheme;
      user = map user Username.of_string;
      password = map password Password.of_string;
      host = Host.of_string host;
      port = map port Port.of_int;
      path = Path.of_string path;
      params = map params Params.of_list;
      fragment = map fragment Fragment.of_string;
    }))
  )
  ~fields:[
    arg  "scheme" ~typ:(non_null scheme_input);
    arg  "user" ~typ:string;
    arg  "password" ~typ:string;
    arg  "host" ~typ:(non_null string);
    arg  "port" ~typ:int;
    arg' "path" ~typ:string ~default:"";
    arg  "params" ~typ:(list (non_null param_input));
    arg  "fragment" ~typ:string;
  ])


exception URL_missing of int

let or_id_resolver db_conn = Model.Url.(function
  | URL url -> Lwt.return url
  | ID id -> DB.Select.url_by_id db_conn (ID.to_int id) >>= function
    | Some url -> Lwt.return url
    | None -> Lwt.fail (URL_missing (ID.to_int id))
)