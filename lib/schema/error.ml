
open Core
open Graphql_lwt

module Code = struct
  type t = 
      Bad_request
    | Internal_server_error
end

exception E of Code.t * string

type t = {
  code: Code.t;
  message: string;
}

let code = Schema.(Code.(enum "ErrorCode" ~values:[
  enum_value "BadRequest" ~value:Bad_request;
  enum_value "InternalServerError" ~value:Internal_server_error;
]))

let error = Schema.(obj "Error"
  ~fields:(fun error -> [
    field "code"
      ~args:Arg.[]
      ~typ:(non_null code)
      ~resolve:(fun () e -> e.code)
    ;
    field "message"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () e -> e.message)
    ;
  ])
)

let make_x_or_error type_name ~x_name ~x_type ~resolve_error ~resolve_x =
  Schema.(obj type_name ~fields:(fun x_or_error -> [
    field "error"
      ~args:Arg.[]
      ~typ:error
      ~resolve:resolve_error
    ;
    field x_name
      ~args:Arg.[]
      ~typ:x_type
      ~resolve:resolve_x
    ;
  ])
)

let of_unexpected error = {
  code = Code.Internal_server_error;
  message = "An unexpected error occurred: " ^ (Exn.to_string error);
}
  
let of_exception = function
  | E (code, message) -> { code; message; }
  | e -> of_unexpected e