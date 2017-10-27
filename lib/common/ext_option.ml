
include Core.Option

let ( =?: ) maybe fallback = match maybe with 
  | None -> Lazy.force fallback
  | Some value -> value

let ( =!?: ) (maybe, transform) fallback = match maybe with
  | None -> Lazy.force fallback
  | Some value -> transform value