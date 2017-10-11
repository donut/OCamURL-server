
open Util
open Model
open Printf

module Mdb = Mariadb.Blocking

let url url' = 
  let module M = Mdb in
  let query = 
    "INSERT INTO url " 
      ^ "(scheme, user, password, host, port, path, params, fragment) "
      ^ "VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
  in
  let stmt = M.prepare connect query |> or_die "prepare" in
  let maybe_string transform maybe = match maybe with
    | None -> `Null
    | Some s -> `String (transform s)
  in
  let res = M.Stmt.execute stmt Url.([|
    `String (Scheme.to_string url'.scheme);
    maybe_string (Username.to_string) url'.user
    maybe_string (Password.to_string) url'.password
    `String (Host.to_string url'.host);
    (match url'.port with 
      | Some p -> `Int (Port.to_int p) | None -> `Null);
    `String (Path.to_string url'.path);
    maybe_string (Params.to_string) url'.params
    maybe_string (Fragment.to_string) url'.fragment
  |]) |> or_die "execute" in
  begin match res with
  | Some res ->
    printf "#rows: %d\n%!" (M.Res.num_rows res);
    let s = stream res |> or_die "stream" in
    Stream.iter print_row s
  | None -> ()
  end;
  M.Stmt.close stmt |> or_die "close statement";
  M.close connect