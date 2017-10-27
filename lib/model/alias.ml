
open Lib_common

module Name : Convertable.StringType = Convertable.String
module Disabled : Convertable.BoolType = Convertable.Bool

type t = {
  name: Name.t;
  url: Url.t;
  disabled: Disabled.t;
}