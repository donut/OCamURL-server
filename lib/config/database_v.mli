(* Auto-generated from "database.atd" *)


type t = Database_t.t = {
  host: string;
  port: int;
  user: string;
  pass: string;
  database: string
}

val create_t :
  ?host: string ->
  ?port: int ->
  ?user: string ->
  ?pass: string ->
  database: string ->
  unit -> t
  (** Create a record of type {!t}. *)

val validate_t :
  Ag_util.Validation.path -> t -> Ag_util.Validation.error option
  (** Validate a value of type {!t}. *)

