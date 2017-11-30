(* Auto-generated from "api.atd" *)


type database = Database_t.t

type t = Api_t.t = { port: int; database: database; alias_alphabet: string }

val validate_database :
  Ag_util.Validation.path -> database -> Ag_util.Validation.error option
  (** Validate a value of type {!database}. *)

val create_t :
  port: int ->
  database: database ->
  alias_alphabet: string ->
  unit -> t
  (** Create a record of type {!t}. *)

val validate_t :
  Ag_util.Validation.path -> t -> Ag_util.Validation.error option
  (** Validate a value of type {!t}. *)

