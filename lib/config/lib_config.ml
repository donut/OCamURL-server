
module API = struct 
	include Api_t
	let of_string = Api_j.t_of_string
end
module Alias_redirect = struct
	include Alias_redirect_t
	let of_string = Alias_redirect_j.t_of_string
end
module CLI = Cli

let of_file = Read.config
