
open Graphql_lwt

module Opt = Core.Option
module Model = Lib_model


let use = Model.Use.(Graphql_lwt.Schema.(obj "Use"
  ~fields:(fun use -> [
    field "id"
      ~args:Arg.[]
      ~typ:(non_null guid)
      ~resolve:(fun () p -> p.id |> ID.to_int |> string_of_int)
    ;
    field "alias"
      ~args:Arg.[]
      ~typ:(non_null Alias.alias)
      ~resolve:(fun () p -> p.alias)
    ;
    field "url"
      ~args:Arg.[]
      ~typ:(non_null Url.url)
      ~resolve:(fun () p-> p.url)
    ;
    field "referer"
      ~args:Arg.[]
      ~typ:Url.url
      ~resolve:(fun () p -> p.referer)
    ;
    field "user_agent"
      ~args:Arg.[]
      ~typ:string
      ~resolve:(fun () p -> Opt.map p.user_agent UserAgent.to_string)
    ;
    field "ip"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> IP.to_string p.ip)
    ;
    field "timestamp"
      ~args:Arg.[]
      ~typ:(non_null int)
      ~resolve:(fun () p -> Timestamp.to_int p.timestamp)
    ;
  ])
))