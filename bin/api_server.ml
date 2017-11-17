
open Lwt.Infix

module Conf = Lib.Config
module DB = Lib.DB
module Gql = Graphql_lwt
module Schema = Lib.Schema


let schema db_conn (config:Conf.API.t) = Gql.Schema.(Schema.(schema [
    Aliases_qry.field db_conn;
    Url_qry.field db_conn;
  ]
  ~mutations:[
    Add_alias_mut.field db_conn;
    Change_alias_url_mut.field db_conn;
    Delete_alias_mut.field db_conn;
    Disable_alias_mut.field db_conn;
    Enable_alias_mut.field db_conn;
    Generate_alias_mut.field db_conn config.alias_alphabet;
    Rename_alias_mut.field db_conn;
  ]
))

let main (config:Conf.API.t) =
  let db = config.database in
  DB.connect
    ~host:db.host ~user:db.user ~pass:db.pass ~db:db.database ()
    >>= DB.or_die "connect" >>= fun db_conn ->

  Gql.Server.start ~port:config.port ~ctx:(fun () -> ()) (schema db_conn config)
  >>= fun () ->

  DB.close db_conn

let start (config:Conf.API.t) = 
  Lwt_main.run @@ main config
