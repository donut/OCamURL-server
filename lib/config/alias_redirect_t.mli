(* Auto-generated from "alias_redirect.atd" *)


type database = Database_t.t

type cache = { max_record_age: float; target_length: int; trim_length: int }

type t = {
  port: int;
  database: database;
  cache: cache;
  pathless_redirect_uri: string option;
  error_404_page_path: string option;
  error_50x_page_path: string option
}
