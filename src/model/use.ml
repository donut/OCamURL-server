
open Helpers

module ID : Convertable.IntType = Convertable.Int
module UserAgent : Convertable.StringType = Convertable.String
module IP : Convertable.StringType = Convertable.String
module Timestamp : Convertable.IntType = Convertable.Int

type t = {
  id: ID.t;
  alias: Alias.t;
  url: Url.t;
  referer: Url.t option;
  user_agent: UserAgent.t option;
  ip: IP.t;
  timestamp: Timestamp.t;
}