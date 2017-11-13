open Graphql_lwt
open Lwt.Infix
open Printf

module DB = Lib_db
module Model = Lib_model

type input = {
  url: Model.Url.t;
  client_mutation_id: string;
}

type payload = {
  alias: Model.Alias.t;
  client_mutation_id: string;
}

type payload_or_error = {
  error: Error.t option;
  payload: payload option;
}

let input = Schema.Arg.(obj "GenerateAliasInput"
  ~coerce:(fun url client_mutation_id -> { url; client_mutation_id; })
  ~fields:[
    arg "url" ~typ:(non_null (Url.input "GenerateAliasURLInput"));
    arg "clientMutationId" ~typ:(non_null string);
  ]
)

let payload db_conn = Schema.(obj "GenerateAliasPayload"
  ~fields:(fun payload -> [
    field "alias"
      ~args:Arg.[]
      ~typ:(non_null (Alias.alias db_conn))
      ~resolve:(fun () p -> p.alias)
    ;
    field "clientMutationId"
      ~args:Arg.[]
      ~typ:(non_null string)
      ~resolve:(fun () p -> p.client_mutation_id)
    ;
  ])
)

let payload_or_error db_conn = Error.make_x_or_error "AddAliasPayloadOrError"
  ~x_name:"payload" ~x_type:(payload db_conn)
  ~resolve_error:(fun () p -> p.error)
  ~resolve_x:(fun () p -> p.payload)

(** An injective function that generates a distinct name for the passed
    integer using a set alphabet.

    WARNING: Changing could create a greater likelihood of collisions with
    those already in database.
    
    @see https://stackoverflow.com/a/742047/134014 *)
let generate_name_from_int int =
  let rec chars_of_string = String.(function
    | "" -> []
    | str -> get str 0 :: (chars_of_string @@ sub str 1 @@ length str - 1)
  ) in

  (** Shuffled list of URI unreserved characters (RFC3986, [a-zA-Z0-0_-.~]).
      @see https://tools.ietf.org/html/rfc3986#section-2.3

      Shuffled to help prevent being guessable. However, once this is open
      sourced this will be an open secret. Should be refactered to use config
      or database so it can be instance specific. Maybe have a config to
      specify the alphabet and then, on first DB initialization, randomize
      list and store in DB.
  *)
  let alphabet = 
    "621coIKZhSEn8rwsq0eg5~QfBWpNV4u.iDyvzMadTtYkGm3FxjO_9HL7CJAb-XPRlU" in
  let base = String.length alphabet in
  let char_list = chars_of_string alphabet in

  let rec indexify = function
    | 0 -> []
    | num -> (num mod base) :: indexify (num / base)
  in

  let rec encode indexes = 
    let get_char = List.nth char_list in
    match indexes with 
      | [] -> []
      | [x] -> [get_char x]
      | x :: remainder -> get_char x :: encode remainder
    in

  let string_of_chars lst =
    lst |> List.map (String.make 1) |> String.concat ""
  in

  int |> indexify |> encode |> string_of_chars

(** Generate an interesting, likely unique name.

    WARNING: Changing the logic of this function could result in higher name
    collisions with existing names created before the change.

    When generating a name I came up with a few criteria:
   
    * Names shouldn't be too short or too long (4 < length < 9).
    * They should appear random to the user without a discernable pattern,
      making them less predictable/guessable.
    * Consecutively created names should not appear similar.

    My first thought, inspired by a StackOverflow answer[1], was to use the ID
    of the inserted alias. The ID would always be unique and could be converted
    to a string injectively (@see `generate_name_from_int`). But this ran into
    several problems: 

    * Starting, the low-number IDs resulted in very short names. This would
      get better with time. But for small user basis, that would take a long
      time.
    * Since the database simply uses auto-increment for IDs, the sequential IDs
      result in sequential names. This leads to names that look similar to 
      each other with just one character changed. Makes them predictable.
    
    With these things in mind I tried combining the IDs with random numbers
    or the second since the Unix epoch. But I couldn't find a way where I was
    satisfied with the output. Looking for other ways, I realized I was
    mentally stuck on using the row ID. Freeing myself form that, I came to
    the following solution.

    If I just relied on the seconds since the Unix epoch, we would run into
    the same problems of the sequential IDs. Each name would have significant
    similarities to previous names. Especially with so many significant digits
    not changing. By sticking the fraction of a second at the front of the
    number, the whole number changes significantly at every generation.

   [1]: https://stackoverflow.com/a/742047/134014
*)
let generate_name () =
  Unix.gettimeofday () |> sprintf "%.3f"
    |> String.split_on_char '.' |> List.rev |> String.concat ""
    |> int_of_string |> generate_name_from_int

let insert_alias_with_unique_name db_conn url_or_id status =
  let rec insert name =
    DB.Select.id_of_alias db_conn name >>= function
    | Some _ -> insert (generate_name ())
    | None -> 
      let alias = Model.Alias.({
        name = Name.of_string name;
        url = url_or_id;
        status = status;
      }) in
      DB.Insert.alias db_conn alias >>= fun () ->
      Lwt.return name
  in
  insert (generate_name ()) >>= Lwt.return

let resolver db_conn = fun () () { url; client_mutation_id; }
-> DB.(Model.(Error.(
  Lwt.catch
  (fun () ->
    Insert.url_if_missing db_conn url >>= fun id ->

    let url' = { url with id = Some (Url.ID.of_int id) } in
    let url_or_id = (Url.URL url') in
    let status = Alias.Status.Enabled in
    insert_alias_with_unique_name db_conn url_or_id status >>= fun name ->

    let alias = Alias.({
      name = Name.of_string name;
      url = url_or_id;
      status = status;
    }) in
    let payload = { alias = alias; client_mutation_id; } in 
    Lwt.return { error = None; payload = Some payload; }
  )
  (fun exn ->
    Lwt.return { error = Some (of_exn exn); payload = None; }
  )
)))

let field db_conn = Schema.(io_field "generateAlias"
  ~typ:(non_null (payload_or_error db_conn))
  ~args:Arg.[
    arg "input" ~typ:(non_null input);
  ]
  ~resolve:(resolver db_conn)
)