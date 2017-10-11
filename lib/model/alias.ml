
open Lib_common

module Name : Convertable.StringType = Convertable.String

type t = {
  name: Name.t;
  url: Url.t;
}