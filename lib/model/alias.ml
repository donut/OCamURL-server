
open Lib_common

module ID : Convertable.IntType = Convertable.Int
module Name : Convertable.StringType = Convertable.String

module Status = struct
  type t = Enabled | Disabled
  exception No_matching_string of string
  let of_string s = match String.lowercase_ascii s with
    | "enabled" -> Enabled
    | "disabled" -> Disabled
    | _ -> raise (No_matching_string s)
  let to_string = function
    | Enabled -> "enabled"
    | Disabled -> "disabled"
end

type t = {
  id: ID.t option;
  name: Name.t;
  url: Url.or_id;
  status: Status.t;
}

type or_id = Alias of t | ID of ID.t