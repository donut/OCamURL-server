

open Lib_common
open Lib_common.Ext_option

module Scheme  = struct
  type t = HTTP | HTTPS
  exception No_matching_string of string
  let of_string s = match String.lowercase_ascii s with
    | "http" -> HTTP | "https" -> HTTPS
    | _ -> raise (No_matching_string s)
  let of_string_opt s = 
    try Some (of_string s) with _ -> None
  let to_string = function HTTP -> "http" | HTTPS -> "https"
end

module ID : Convertable.IntType = Convertable.Int
module Username : Convertable.StringType = Convertable.String
module Password : Convertable.StringType = Convertable.String
module Host : Convertable.StringType = Convertable.String
module Port : Convertable.IntType = Convertable.Int

module Path : Convertable.StringType = struct
  type t = string
  let of_string x = x
  let to_string x = 
    if String.length x > 0 && not (Char.equal (String.get x 0) '/')
    then "/" ^ x else x
end

type param = { key: string; value: string option; }

module Params : sig
  type t
  val of_list : param list -> t
  val to_list : t -> param list
  val of_string : string -> t
  val to_string : t -> string
end = struct
  type t = param list
  let of_list x = x
  let to_list x = x
  let of_string x =
    let dec = Uri.pct_decode in
    String.split_on_char '&' x
    |> List.map (String.split_on_char '=')
    |> List.map (function 
      | [] -> { key = ""; value = None }
      | [key] -> { key = dec key; value = None }
      | [key; value] -> { key = dec key; value = Some (dec value) }
      | key :: value -> {
        key = dec key;
        value = Some (String.concat "=" value |> dec)
      }
    )
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
    String.concat "&" @@ pair_up x
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

type or_id = URL of t | ID of ID.t

let of_ref = function
  | `ID id -> ID id
  | `Int id -> ID (ID.of_int id)
  | `Rec r -> URL r
  | `Ref ref -> ref

let id_of_ref = function
  | ID id 
  | URL { id = Some id } -> Some id
  | _ -> None

let to_string url =
  let opt_to_str maybe prefix to_string =
    (maybe, (^) prefix <% to_string) =!?: lazy "" in

  let scheme = Scheme.to_string url.scheme in
  let user = opt_to_str url.user "" Username.to_string in
  let password = opt_to_str url.password ":" Password.to_string in
  let auth = match (url.user, url.password) with
    | (None, None) -> "" 
    | _ -> user ^ password ^ "@" in
  let host = Host.to_string url.host in
  let path = Path.to_string url.path in
  let port = opt_to_str url.port ":" (Port.to_int %> string_of_int) in
  let params = opt_to_str url.params "?" Params.to_string in
  let fragment = opt_to_str url.fragment "#" Fragment.to_string in

  scheme ^ "://" ^ auth ^ host ^ port ^ path ^ params ^ fragment


let of_string url =
  let module Opt = Core.Option in
  let uri = Uri.of_string url in
  let scheme = Scheme.of_string_opt (Uri.scheme uri =?: lazy "https")  
    =?: lazy Scheme.HTTPS in
  {
    id = None;
    scheme;
    user = map (Uri.user uri) (Username.of_string);
    password = map (Uri.password uri) (Password.of_string);
    host = Host.of_string @@ Uri.host_with_default ~default:"" uri;
    port = map (Uri.port uri) (Port.of_int);
    path = Path.of_string @@ Uri.path uri;
    params = map (Uri.verbatim_query uri) (Params.of_string);
    fragment = map (Uri.fragment uri) (Fragment.of_string);
  }