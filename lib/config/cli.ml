
open Core


let start_command callback = Command.(
	basic
		~summary:"Start a OCamURL server."
		Spec.(empty
			+> anon ("service_name" %: string) 
			+> anon ("config_path" %: file))
		callback
)
