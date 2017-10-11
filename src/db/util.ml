
open Printf
module Mdb = Mariadb.Blocking

let print_row row =
  let module M = Mariadb.Blocking in
  printf "---\n%!";
  M.Row.StringMap.iter
    (fun name field ->
      printf "%20s " name;
      match M.Field.value field with
      | `Int i -> printf "%d\n%!" i
      | `Float x -> printf "%f\n%!" x
      | `String s -> printf "%s\n%!" s
      | `Bytes b -> printf "%s\n%!" "Bytes! :)"
      | `Time t ->
          printf "%04d-%02d-%02d %02d:%02d:%02d\n%!"
            (M.Time.year t)
          (M.Time.month t)
          (M.Time.day t)
          (M.Time.hour t)
          (M.Time.minute t)
          (M.Time.second t)
    | `Null -> printf "NULL\n%!")
  row

let stream res =
  let module M = Mariadb.Blocking in
  let module F = struct exception E of M.error end in
  let next _ =
    match M.Res.fetch (module M.Row.Map) res with
    | Ok (Some _ as row) -> row
    | Ok None -> None
    | Error e -> raise (F.E e) in
  try Ok (Stream.from next)
  with F.E e -> Error e

let or_die where = function
  | Ok x -> x
  | Error (num, msg) -> failwith @@ sprintf "%s #%d: %s" where num msg 

let connect = Mdb.connect
  ~host:"localhost"
  ~user:"root"
  ~pass:""
  ~db:"rtmDOTtv" () |> or_die "connect"