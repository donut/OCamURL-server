
open Core


let config_of_file to_config filename callback = 
	callback @@ Read.config to_config filename

let start_api_command to_config callback = Command.(
	basic
		~summary:"Start the API server."
		Spec.(empty +> anon ("config" %: file))
		(fun filename () -> config_of_file to_config filename callback)
)
