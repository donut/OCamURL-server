
open Helpers

module Scheme : sig
  type t = HTTP | HTTPS
  val to_string : t -> string
end = struct
  type t = HTTP | HTTPS
  let to_string = function HTTP -> "http" | HTTPS -> "https"
end

module ID : Convertable.IntType = Convertable.Int
module Username : Convertable.StringType = Convertable.String
module Password : Convertable.StringType = Convertable.String
module Host : Convertable.StringType = Convertable.String
module Port : Convertable.IntType = Convertable.Int
module Path : Convertable.StringType = Convertable.String

type param = { key: string; value: string option; }

module Params : sig
  type t
  val of_list : param list -> t
  val to_list : t -> param list
end = struct
  type t = param list
  let of_list x = x
  let to_list x = x
end

module Fragment : Convertable.StringType = Convertable.String

type t = {
  id: ID.t option;
  scheme: Scheme.t;
  user: Username.t option;
  password: Password.t option;
  host: Host.t;
  port: Port.t option;
  path: Path.t;
  params: Params.t option;
  fragment: Fragment.t option;
}
