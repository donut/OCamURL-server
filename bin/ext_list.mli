
include (module type of List)

(** Get last item in list. *)
val last : 'a list -> 'a

(** Get last item of list as an optional. *)
val last_opt : 'a list -> 'a option
