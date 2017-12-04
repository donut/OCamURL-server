
open Lwt.Infix

module Conf = Lib.Config
module DB = Lib.DB
module Gql = Graphql_lwt
module Schema = Lib.Schema


let make_schema db_handle (conf:Conf.API.t) =
  let reserved = conf.reserved in

  Gql.Schema.(Schema.(schema
    [
      Aliases_qry.field db_handle;
      Url_qry.field db_handle;
    ]
    ~mutations:[
      Add_alias_mut.field ~db_handle ~reserved;
      Change_alias_url_mut.field db_handle;
      Delete_alias_mut.field db_handle;
      Disable_alias_mut.field db_handle;
      Enable_alias_mut.field db_handle;
      Generate_alias_mut.field
        ~db_handle ~alphabet:conf.alias_alphabet ~reserved;
      Rename_alias_mut.field ~db_handle ~reserved;
    ]
  ))

let main (config:Conf.API.t) =
  let db = config.database in
  let db_connect = DB.make_connect_func
		~host:db.host ~user:db.user ~pass:db.pass ~db:db.database () in
  let schema = make_schema db_connect config in

  Gql.Server.start ~port:config.port ~ctx:(fun () -> ()) schema >>= fun () ->

  DB.final_close ();
  Lwt.return_unit

let start (config:Conf.API.t) = 
  Lwt_main.run @@ main config
