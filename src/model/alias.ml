
open Common

module Name : StringConvertableType = StringConvertable

type t = {
  name: Name.t;
  url: Url.t;
}