
open Lib_common

module ID : Convertable.IntType = Convertable.Int
module UserAgent : Convertable.StringType = Convertable.String
module IP : Convertable.StringType = Convertable.String
module Timestamp : Convertable.IntType = Convertable.Int

type t = {
  id: ID.t option;
  alias: Alias.or_id;
  url: Url.or_id;
  referer: Url.or_id option;
  user_agent: UserAgent.t option;
  ip: IP.t;
  timestamp: Timestamp.t;
}