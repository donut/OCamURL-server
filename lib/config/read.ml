
let read_file filename =
	Core.In_channel.read_all filename

let config filename to_config =
	to_config @@ read_file filename