
let ( =?: ) maybe fallback = match maybe with 
  | None -> Lazy.force fallback
  | Some value -> value