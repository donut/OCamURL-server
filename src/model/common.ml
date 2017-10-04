
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