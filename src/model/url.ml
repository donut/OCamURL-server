
module type IntConvertableType = sig
  type t
  val of_int : int -> t
  val to_int : t -> int
end

module IntConvertable = struct
  type t = int
  let of_int x = x
  let to_int x = x
end

module type StringConvertableType = sig
  type t
  val of_string : string -> t
  val to_string : t -> string
end

module StringConvertable = struct
  type t = string
  let of_string x = x
  let to_string x = x
end

module Scheme : sig
  type t = HTTP | HTTPS
  val to_string : t -> string
end = struct
  type t = HTTP | HTTPS
  let to_string = function HTTP -> "http" | HTTPS -> "https"
end

module ID : IntConvertableType = IntConvertable
module Username : StringConvertableType = StringConvertable
module Password : StringConvertableType = StringConvertable
module Host : StringConvertableType = StringConvertable
module Port : IntConvertableType = IntConvertable
module Path : StringConvertableType = StringConvertable

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

module Fragment : StringConvertableType = StringConvertable

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
