(* Auto-generated from "api.atd" *)


type database = {
  host: string;
  port: int;
  user: string;
  pass: string;
  database: string
}

type t = { port: int; database: database; alias_alphabet: string }
