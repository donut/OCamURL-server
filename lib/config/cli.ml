
open Core


let start_service_command callback = Command.(
	basic
		~summary:"Start an OCamURL server."
		Spec.(empty
			+> anon ("service_name" %: string) 
			+> anon ("config_path" %: file))
		callback
)
