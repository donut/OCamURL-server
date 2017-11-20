
open Graphql_lwt
open Lwt.Infix

module Model = Lib_model
module DB = Lib_db

let status = Schema.(enum "URLScheme" ~values:Model.Alias.Status.([
  enum_value "disabled" ~value:Disabled;
  enum_value "enabled" ~value:Enabled;
]))

let alias db_conn = Model.Alias.(Graphql_lwt.Schema.(obj "Alias"
  ~fields:(fun alias -> [
    field "id"
      ~args:Arg.[]
      ~typ:(non_null guid)
      ~resolve:(fun () alias ->
        let exception Alias_missing_id of string in
        match alias.id with 
        | None ->
          let name = Name.to_string alias.name in
          ignore @@
            Lwt_io.printlf "Alias [%s] missing ID when it never should." name;
          raise (Alias_missing_id name)
        | Some id -> id |> ID.to_int |> string_of_int)
    ;
    field "name"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () a -> Name.to_string a.name)
    ;
    io_field "url"
      ~args:Arg.[]
      ~typ:(non_null Url.url)
      ~resolve:(fun () a ->
        Lwt.catch
        (fun () -> Url.or_id_resolver db_conn a.url >>= Lwt.return)
        (fun exn -> 
          Lwt_io.printlf "Failed resolving URL for alias %s: %s"
            (Name.to_string a.name) (Core.Exn.to_string exn)
          >>= fun () -> raise exn
        )
      )
    ;
    field "status"
      ~args:Arg.[]
      ~typ:(non_null status)
      ~resolve:(fun () a -> a.status)
    ;
  ])
))