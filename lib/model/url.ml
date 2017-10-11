

open Lib_common
open Lib_common.Option

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
  val to_string : t -> string
end = struct
  type t = param list
  let of_list x = x
  let to_list x = x
  let to_string x = 
    let pair_up = List.map (fun { key; value; } ->
      let enc = Uri.pct_encode  in 
      let k = enc ~component:`Query_key key in
      let v = match value with 
        | None -> ""
        | Some v ->
          "=" ^ enc ~component:`Query_value (value =?: lazy "") in
      k ^ v
    ) in
    let rec join lst = match lst with
      | [] -> ""
      | [pair] -> pair
      | pair :: remainder -> pair ^ "&" ^ (join remainder)
    in
    join @@ pair_up x
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
