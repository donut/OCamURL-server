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

val validate_file :
  Ag_util.Validation.path -> file -> Ag_util.Validation.error option
  (** Validate a value of type {!file}. *)

val validate_database :
  Ag_util.Validation.path -> database -> Ag_util.Validation.error option
  (** Validate a value of type {!database}. *)

val create_cache :
  max_record_age: float ->
  target_length: int ->
  trim_length: int ->
  unit -> cache
  (** Create a record of type {!cache}. *)

val validate_cache :
  Ag_util.Validation.path -> cache -> Ag_util.Validation.error option
  (** Validate a value of type {!cache}. *)

val create_t :
  port: int ->
  database: database ->
  cache: cache ->
  ?pathless_redirect_uri: string ->
  ?error_404_page_path: file ->
  ?error_50x_page_path: file ->
  unit -> t
  (** Create a record of type {!t}. *)

val validate_t :
  Ag_util.Validation.path -> t -> Ag_util.Validation.error option
  (** Validate a value of type {!t}. *)

