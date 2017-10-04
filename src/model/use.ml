
open Common

module ID : IntConvertableType = IntConvertable
module UserAgent : StringConvertableType = StringConvertable
module IP : StringConvertableType = StringConvertable
module Timestamp : IntConvertableType = IntConvertable

type t = {
  id: ID.t;
  alias: Alias.t;
  url: Url.t;
  referer: Url.t option;
  user_agent: UserAgent.t option;
  ip: IP.t;
  timestamp: Timestamp.t;
}