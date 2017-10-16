
open Util
open Lib_model
open Lib_common
open Printf

exception ID_not_int

let first_row_of_result = function
  | None -> None
  | Some res -> match Mdb.Res.num_rows res with 
    | 0 -> None
    | _ -> Some (Stream.next (stream res |> or_die "stream"))

let id_of_first_row = fun result ->
  match first_row_of_result result with
  | None -> None
  | Some row -> 
    match (row |> Mdb.Row.StringMap.find "id" |> Mdb.Field.value) with
      | `Int id -> Some id
      | _ -> raise ID_not_int

let id_of_alias connection name =
  let query = "SELECT id FROM alias WHERE name = ?" in
  let values = [| `String name |] in
  execute_query connection query values id_of_first_row

let id_of_url connection url = 
  let values = values_of_url url |> Array.to_list in
  let where = List.combine url_fields values
    |> List.map (function 
      | (field, `Null) -> field ^ " IS NULL"
      | (field,     _) -> field ^ " = ?"
    )
    |> String.concat " AND "
  in
  let values' = values |> List.filter (function `Null -> false | _ -> true) in

  let query = 
    "SELECT id FROM url WHERE " ^ where ^ " ORDER BY id ASC LIMIT 1"
  in 
  execute_query connection query (Array.of_list values') id_of_first_row


let url_of_alias connection name =
  let fields = "id" :: url_fields in
  let select = fields
    |> List.map (fun f -> "url." ^ f ^ " AS " ^ f)
    |> String.concat ", "in
  let query = 
    "SELECT " ^ select ^ " FROM alias "
     ^ "JOIN url ON url.id = alias.url "
     ^ "WHERE alias.name = ? "
     ^ "ORDER BY url.id LIMIT 1" in
  execute_query connection query [| `String name |] (fun result ->
    match first_row_of_result result with
    | None -> None
    | Some row -> Some Url.(
      {
        id = maybe_int_of_map row "id" (ID.of_int);
        scheme = string_of_map row "scheme" |> Scheme.of_string;
        user = maybe_string_of_map row "user" (Username.of_string);
        password = maybe_string_of_map row "password" (Password.of_string);
        host = string_of_map row "host" |> Host.of_string;
        port = maybe_int_of_map row "port" (Port.of_int);
        path = string_of_map row "path" |> Path.of_string;
        params = maybe_string_of_map row "params" (Params.of_string);
        fragment = maybe_string_of_map row "fragment" (Fragment.of_string);
      }
    )
  )