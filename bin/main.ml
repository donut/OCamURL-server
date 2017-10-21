
open Core
open Str

open Lwt

open Lib.Common.Ext_list

module DB = Lib.DB
module Schema = Lib.Schema
module Gql = Graphql_lwt


let schema db_connection = Gql.Schema.(Schema.(schema [
    field "url"
      ~args:Arg.[
        arg "alias" ~typ:(non_null string);
      ]
      ~typ:Url.url
      ~resolve:(fun () () name -> 
        DB.Select.url_of_alias db_connection name
      )
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