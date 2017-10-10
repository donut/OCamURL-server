
open Graphql_lwt

module GqlSchema = Graphql_lwt.Schema
module Opt = Core.Option

let scheme_values = Model.Url.Scheme.(GqlSchema.([
    enum_value "http" ~value:HTTP;
    enum_value "https" ~value:HTTPS;
]))

let scheme =
  GqlSchema.(enum "URLScheme" ~values:scheme_values)

let param = Model.Url.(GqlSchema.(obj "URLParam"
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

let url = Model.Url.(GqlSchema.(obj "URL"
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
  ])
))