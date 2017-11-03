
open Lwt.Infix
open Graphql_lwt

module DB = Lib_db
module Model = Lib_model

type or_error = {
  error: Error.t option;
  aliases:  Model.Alias.t list option;
}

let aliases_or_error db_conn = Error.make_x_or_error "AliasesOrError"
  ~x_name:"aliases" ~x_type:Schema.(list (non_null (Alias.alias db_conn)))
  ~resolve_error:(fun () o -> o.error)
  ~resolve_x:(fun () o -> o.aliases)

let field db_conn = Schema.(io_field "aliases"
  ~args:Arg.[
    arg "urlID" ~typ:guid;
    arg "url" ~typ:(Url.input "AliasesURLInput");
  ]
  ~typ:(non_null (aliases_or_error db_conn))
  ~resolve:(fun () () id url -> DB.(
    Lwt.catch (fun () ->
      begin match (id, url) with
        | (None, None) -> raise Error.(
          E (Code.Bad_request, "`urlID` or `url` parameter required."))
        | (Some _, Some _) -> raise Error.(
          E (Code.Bad_request, "Pass either `urlID` or `url`, not both."))
        | (Some id, _) -> Lwt.return @@ int_of_string_opt id
        | (_, Some url) -> Select.id_of_url db_conn url
      end >>= (function
      | None -> Lwt.return []
      | Some id -> Select.aliases_of_url db_conn id) >>= fun lst ->
        Lwt.return { error = None; aliases = Some lst; }
    )
    (fun exn ->
      Lwt.return { error = Some (Error.of_exn exn); aliases = None; })
  ))
)