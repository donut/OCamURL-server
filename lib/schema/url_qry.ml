
open Lwt.Infix
open Graphql_lwt

module DB = Lib_db

let field db_conn = Schema.(io_field "url"
  ~args:Arg.[
    arg "alias" ~typ:(non_null string);
  ]
  ~typ:(non_null Url.or_error)
  ~resolve:(fun () () name -> Url.(
    Lwt.catch (fun () ->
      DB.Select.url_of_alias db_conn name >>= fun url ->
      Lwt.return { error = None; url; })
    (fun exn ->
      Lwt.return { error = Some (Error.of_exception exn); url = None; })
  ))
)