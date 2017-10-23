
open Lwt

module DB = Lib.DB
module Gql = Graphql_lwt
module Schema = Lib.Schema


let schema db_connection = Gql.Schema.(Schema.(schema [
    Url_qry.field db_connection;
  ]
  ~mutations:[
    Put_alias_mut.field db_connection;
  ]
))

let () =
  let connection = DB.connect
    ~host:"localhost" ~user:"root" ~pass:"" ~db:"rtmDOTtv" ()
    |> Lib.DB.or_die "connect"
  in

  Gql.Server.start ~ctx:(fun () -> ()) (schema connection) |> Lwt_main.run;

  DB.close connection;