
open Lwt.Infix

module DB = Lib.DB
module Gql = Graphql_lwt
module Schema = Lib.Schema


let schema db_conn = Gql.Schema.(Schema.(schema [
    Aliases_qry.field db_conn;
    Url_qry.field db_conn;
  ]
  ~mutations:[
    Add_alias_mut.field db_conn;
    Disable_alias_mut.field db_conn;
    Enable_alias_mut.field db_conn;
    Generate_alias_mut.field db_conn;
  ]
))

let main () =
  DB.connect
    ~host:"localhost" ~user:"root" ~pass:"" ~db:"rtmDOTtv" ()
    >>= DB.or_die "connect" >>= fun db_conn ->

  Gql.Server.start ~ctx:(fun () -> ()) (schema db_conn) >>= fun () ->

  DB.close db_conn

let () =
   Lwt_main.run @@ main ()