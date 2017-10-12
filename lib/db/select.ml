
open Util
open Lib_model
open Printf

let url_fields = [
  "scheme"; "user"; "password"; "host"; "port"; "path"; "params"; "fragment";
]

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
  let stmt = Mdb.prepare connection query
    |> or_die "prepare" in

  let result = Mdb.Stmt.execute stmt (Array.of_list values')
    |> or_die "execute" in
   
  let id = match result with 
    | None -> None
    | Some res -> match Mdb.Res.num_rows res with
      | 0 -> None
      | _ -> 
        let row = Stream.next (stream res |> or_die "stream") in
        match (row |> Mdb.Row.StringMap.find "id" |> Mdb.Field.value) with
          | `Int id -> Some id
          | _ -> None
  in

  Mdb.Stmt.close stmt |> or_die "close statement";
  id