
open Graphql_lwt

let alias = Model.Alias.(Graphql_lwt.Schema.(obj "Alias"
  ~fields:(fun alias -> [
    field "id"
      ~args:Arg.[]
      ~typ:(non_null guid)
      ~resolve:(fun () p -> Name.to_string p.name)
    ;
    field "name"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> Name.to_string p.name)
    ;
    field "url"
      ~args:Arg.[]
      ~typ:(non_null Url.url)
      ~resolve:(fun () p -> p.url)
    ;
  ])
))