(* Auto-generated from "api.atd" *)


type database = Database_t.t

type t = Api_t.t = { port: int; database: database; alias_alphabet: string }

let validate_database = (
  Database_v.validate_t
)
let validate_t : _ -> t -> _ = (
  fun path x ->
    (
      validate_database
    ) (`Field "database" :: path) x.database
)
let create_t 
  ~port
  ~database
  ~alias_alphabet
  () : t =
  {
    port = port;
    database = database;
    alias_alphabet = alias_alphabet;
  }
