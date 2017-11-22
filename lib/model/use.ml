
open Lib_common

module ID : Convertable.IntType = Convertable.Int
module User_agent : Convertable.StringType = Convertable.String
module IP : Convertable.StringType = Convertable.String
module Timestamp : Convertable.IntType = Convertable.Int

type t = {
  id: ID.t option;
  alias: Alias.or_id;
  url: Url.or_id;
  referrer: Url.or_id option;
  user_agent: User_agent.t option;
  ip: IP.t;
}

let make ?(id=None) ~alias ~url ?(referrer=None) ?(user_agent=None) ~ip () =
  let module Opt = Core.Option in
  {
    id = Opt.map id ID.of_int;
    alias = Alias.of_ref alias;
    url = Url.of_ref url;
    referrer = Opt.map referrer Url.of_ref;
    user_agent = Opt.map user_agent User_agent.of_string;
    ip = IP.of_string ip;
  }