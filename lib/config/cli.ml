
open Core

let start_service_command callback = Command.(
	basic_spec
		~summary:"Start an OCamURL server."
		~readme:(fun _ -> "")
		Spec.(empty
			+> anon ("service_name" %: string) 
			+> anon ("config_path" %: file))
		callback
)
