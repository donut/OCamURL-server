
open Graphql_lwt

type t = {
  code: int;
  message: string;
}

let error = Schema.(obj "Error"
  ~fields:(fun error -> [
    field "code"
      ~args:Arg.[]
      ~typ:(non_null int)
      ~resolve:(fun () e -> e.code)
    ;
    field "message"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () e -> e.message)
    ;
  ])
)