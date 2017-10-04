
open Common

module Name : Convertable.StringType = Convertable.String

type t = {
  name: Name.t;
  url: Url.t;
}