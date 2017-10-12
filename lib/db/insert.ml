
open Util
open Lib_model
open Printf

let url connection url' = 
  let module M = Mdb in

  let query = 
    "INSERT INTO url " 
      ^ "(scheme, user, password, host, port, path, params, fragment) "
      ^ "VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
  in

  let stmt = M.prepare connection query
    |> or_die "prepare" in
  let res = M.Stmt.execute stmt (values_of_url url')
    |> or_die "execute" in

  begin match res with
  | Some res ->
    printf "#rows: %d\n%!" (M.Res.num_rows res);
    let s = stream res |> or_die "stream" in
    Stream.iter print_row s
  | None -> ()
  end;

  M.Stmt.close stmt |> or_die "close statement";