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

val write_file :
  Bi_outbuf.t -> file -> unit
  (** Output a JSON value of type {!file}. *)

val string_of_file :
  ?len:int -> file -> string
  (** Serialize a value of type {!file}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_file :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> file
  (** Input JSON data of type {!file}. *)

val file_of_string :
  string -> file
  (** Deserialize JSON data of type {!file}. *)

val write_database :
  Bi_outbuf.t -> database -> unit
  (** Output a JSON value of type {!database}. *)

val string_of_database :
  ?len:int -> database -> string
  (** Serialize a value of type {!database}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_database :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> database
  (** Input JSON data of type {!database}. *)

val database_of_string :
  string -> database
  (** Deserialize JSON data of type {!database}. *)

val write_cache :
  Bi_outbuf.t -> cache -> unit
  (** Output a JSON value of type {!cache}. *)

val string_of_cache :
  ?len:int -> cache -> string
  (** Serialize a value of type {!cache}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_cache :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> cache
  (** Input JSON data of type {!cache}. *)

val cache_of_string :
  string -> cache
  (** Deserialize JSON data of type {!cache}. *)

val write_t :
  Bi_outbuf.t -> t -> unit
  (** Output a JSON value of type {!t}. *)

val string_of_t :
  ?len:int -> t -> string
  (** Serialize a value of type {!t}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_t :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> t
  (** Input JSON data of type {!t}. *)

val t_of_string :
  string -> t
  (** Deserialize JSON data of type {!t}. *)

