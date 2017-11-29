
open Core
open Option.Monad_infix

module Hsh = Hashtbl

module Payload = struct
	type t = {
		alias_id: int;
		url_id: int;
		url: string;
	}

	let make ~alias_id ~url_id ~url =
		{ alias_id; url_id; url; }

	let alias_id t = t.alias_id
	let url_id t = t.url_id
	let url t = t.url
end

module Record = struct
	type t = {
		expires: float;
		payload: Payload.t;
	}

	let expires r = r.expires
	let payload r = r.payload

	let make max_age payload = {
		expires = Unix.gettimeofday () +. max_age;
		payload;
	}

	let is_expired t = Unix.gettimeofday () >= t.expires 
end

type t = {
	max_record_age: float;
	target_length: int;
	trim_length: int;
	table: Record.t String.Table.t;
}

let make ~max_record_age ~target_length ~trim_length = {
	max_record_age;
	target_length;
	trim_length;
	table = String.Table.create ();
}
	
let clear_expired t =
	let test r = phys_equal (Record.is_expired r) false in
	Hsh.filter_inplace t.table test

let trim_to_target_length t =
	let list = Hsh.to_alist t.table |> List.sort ~cmp:(fun (_, l) (_, r) ->
		Record.(expires l -. expires r) |> int_of_float) in

	let rec remove_count l count =
		match l, count with
		|  _, 0
		| [], _ -> ()
		| (key, _) :: tl, _ ->
			Hsh.remove t.table key;
			remove_count tl (count - 1)
	in

	remove_count list (Hsh.length t.table - t.target_length)

let clean_up t =
	match Hsh.length t.table >= t.trim_length with
	| false -> ()
	| true ->
		clear_expired t;
		match Hsh.length t.table > t.target_length with
		| false -> ()
		| true ->
			trim_to_target_length t

let set t key payload =
	let data = Record.make t.max_record_age payload in
	Hsh.set t.table ~key ~data;
	clean_up t

let get t key =
	Hsh.find t.table key >>= fun record ->
	match Record.is_expired record with
	| false -> Some (Record.payload record)
	| true -> 
		Hsh.remove t.table key;
		None