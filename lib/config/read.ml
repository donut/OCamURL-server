
let read_file filename =
	Core.In_channel.read_all filename

let config to_config filename =
	Api_j.t_of_string @@ read_file filename