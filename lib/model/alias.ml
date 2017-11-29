
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

let of_ref = function
  | `ID id -> ID id
  | `Int id -> ID (ID.of_int id)
  | `Rec r -> Alias r
  | `Ref ref -> ref

let id_of_ref = function
  | ID id 
  | Alias { id = Some id } -> Some id
  | _ -> None

let make ?id ~name ~url ?(status=Status.Enabled) () =
  let module Opt = Core.Option in
  {
    id = Opt.map id ID.of_int;
    name = Name.of_string name;
    url = Url.of_ref url;
    status = status;
  }

let id t = Core.Option.map t.id ID.to_int
let name t = Name.to_string t.name
let url t = t.url
let status t = t.status
let status_as_string t = Status.to_string t.status