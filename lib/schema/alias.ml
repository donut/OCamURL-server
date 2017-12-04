
open Graphql_lwt
open Lwt.Infix

module M = Lib_model
module DB = Lib_db

let status = Schema.(enum "URLScheme" ~values:M.Alias.Status.([
  enum_value "disabled" ~value:Disabled;
  enum_value "enabled" ~value:Enabled;
]))

let alias db_conn = Graphql_lwt.Schema.(obj "Alias"
  ~fields:(fun alias -> [
    field "id"
      ~args:Arg.[]
      ~typ:(non_null guid)
      ~resolve:(fun () alias ->
        let exception Alias_missing_id of string in
        match M.Alias.id alias with 
        | None ->
          let name = M.Alias.name alias in
          ignore @@
            Lwt_io.printlf "Alias [%s] missing ID when it never should." name;
          raise (Alias_missing_id name)
        | Some id -> id |> string_of_int)
    ;
    field "name"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () a -> M.Alias.name a)
    ;
    io_field "url"
      ~args:Arg.[]
      ~typ:(non_null Url.url)
      ~resolve:(fun () a ->
        Lwt.catch
        (fun () -> Url.or_id_resolver db_conn (M.Alias.url a) >>= Lwt.return)
        (fun exn -> 
          Lwt_io.printlf "Failed resolving URL for alias %s: %s"
            (M.Alias.name a) (Core.Exn.to_string exn)
          >>= fun () -> raise exn
        )
      )
    ;
    field "status"
      ~args:Arg.[]
      ~typ:(non_null status)
      ~resolve:(fun () a -> M.Alias.status a)
    ;
  ])
)

let is_available ~db_handle ~reserved name =
  let patterns = List.map (Re_perl.compile_pat ~opts:[`Caseless]) reserved in
  let test = fun p -> Re.execp p name in
  match List.exists test patterns with
  | true -> Lwt.return false
  | false -> 
    DB.Select.id_of_alias db_handle name >>= fun id -> 
    Lwt.return @@ Core.Option.is_none id

let is_available_exn ~db_handle ~reserved name =
  is_available ~db_handle ~reserved name >>= function
  | false -> raise Error.(
    E (Code.Bad_request,
       "The alias '" ^ name ^ "' already exists or is not allowed."))
  | true -> Lwt.return_unit