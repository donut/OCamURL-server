(* Auto-generated from "alias_redirect.atd" *)


type file = Alias_redirect_t.file

type database = Database_t.t

type cache = Alias_redirect_t.cache = {
  max_record_age: float;
  target_length: int;
  trim_length: int
}

type t = Alias_redirect_t.t = {
  port: int;
  database: database;
  cache: cache;
  pathless_redirect_uri: string option;
  error_404_page_path: file option;
  error_50x_page_path: file option
}

let validate_file = (
  fun path x -> if ( Assert.is_file ) x then None else Some (Ag_util.Validation.error path)
)
let validate_database = (
  Database_v.validate_t
)
let validate_cache : _ -> cache -> _ = (
  fun _ _ -> None
)
let validate__2 = (
  Ag_ov_run.validate_option (
    validate_file
  )
)
let validate__1 = (
  fun _ _ -> None
)
let validate_t : _ -> t -> _ = (
  fun path x ->
    match
      (
        validate_database
      ) (`Field "database" :: path) x.database
    with
      | Some _ as err -> err
      | None ->
        match
          (
            validate__2
          ) (`Field "error_404_page_path" :: path) x.error_404_page_path
        with
          | Some _ as err -> err
          | None ->
            (
              validate__2
            ) (`Field "error_50x_page_path" :: path) x.error_50x_page_path
)
let create_cache 
  ~max_record_age
  ~target_length
  ~trim_length
  () : cache =
  {
    max_record_age = max_record_age;
    target_length = target_length;
    trim_length = trim_length;
  }
let create_t 
  ~port
  ~database
  ~cache
  ?pathless_redirect_uri
  ?error_404_page_path
  ?error_50x_page_path
  () : t =
  {
    port = port;
    database = database;
    cache = cache;
    pathless_redirect_uri = pathless_redirect_uri;
    error_404_page_path = error_404_page_path;
    error_50x_page_path = error_50x_page_path;
  }
