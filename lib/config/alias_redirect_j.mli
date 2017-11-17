(* Auto-generated from "alias_redirect.atd" *)


type database = Database_t.t

type t = Alias_redirect_t.t = {
  port: int;
  database: database;
  pathless_redirect_uri: string option
}

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

