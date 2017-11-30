(* Auto-generated from "database.atd" *)


type t = Database_t.t = {
  host: string;
  port: int;
  user: string;
  pass: string;
  database: string
}

let validate_t : _ -> t -> _ = (
  fun _ _ -> None
)
let create_t 
  ?(host = "localhost")
  ?(port = 3306)
  ?(user = "root")
  ?(pass = "")
  ~database
  () : t =
  {
    host = host;
    port = port;
    user = user;
    pass = pass;
    database = database;
  }
