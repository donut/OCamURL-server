
include List

let rec last = function
  | [] -> raise Not_found
  | [element] -> element
  | _ :: remainder -> last remainder

let last_opt list = 
  try Some (last list) with
    | Not_found -> None