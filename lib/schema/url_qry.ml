
open Graphql_lwt

module DB = Lib_db

let field db_connection = Schema.(field "url"
  ~args:Arg.[
    arg "alias" ~typ:(non_null string);
  ]
  ~typ:(non_null Url.or_error)
  ~resolve:(fun () () name -> Url.(
    try {
      error = None;
      url = DB.Select.url_of_alias db_connection name;
    }
    with e -> { error = Some (Error.of_exception e); url = None; }
  )
))