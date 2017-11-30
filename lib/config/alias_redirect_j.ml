(* Auto-generated from "alias_redirect.atd" *)


type file = Alias_redirect_t.file

type database = Database_t.t

type cache = Alias_redirect_t.cache = {
  max_record_age: float;
  target_length: int;
  trim_length: int
}

type t = Alias_redirect_t.t = {
  port: int;
  database: database;
  cache: cache;
  pathless_redirect_uri: string option;
  error_404_page_path: file option;
  error_50x_page_path: file option
}

let write_file = (
  Yojson.Safe.write_string
)
let string_of_file ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write_file ob x;
  Bi_outbuf.contents ob
let read_file = (
  Ag_oj_run.read_string
)
let file_of_string s =
  read_file (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_database = (
  Database_j.write_t
)
let string_of_database ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write_database ob x;
  Bi_outbuf.contents ob
let read_database = (
  Database_j.read_t
)
let database_of_string s =
  read_database (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_cache : _ -> cache -> _ = (
  fun ob x ->
    Bi_outbuf.add_char ob '{';
    let is_first = ref true in
    if !is_first then
      is_first := false
    else
      Bi_outbuf.add_char ob ',';
    Bi_outbuf.add_string ob "\"max_record_age\":";
    (
      Yojson.Safe.write_float
    )
      ob x.max_record_age;
    if !is_first then
      is_first := false
    else
      Bi_outbuf.add_char ob ',';
    Bi_outbuf.add_string ob "\"target_length\":";
    (
      Yojson.Safe.write_int
    )
      ob x.target_length;
    if !is_first then
      is_first := false
    else
      Bi_outbuf.add_char ob ',';
    Bi_outbuf.add_string ob "\"trim_length\":";
    (
      Yojson.Safe.write_int
    )
      ob x.trim_length;
    Bi_outbuf.add_char ob '}';
)
let string_of_cache ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write_cache ob x;
  Bi_outbuf.contents ob
let read_cache = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field_max_record_age = ref (Obj.magic (Sys.opaque_identity 0.0)) in
    let field_target_length = ref (Obj.magic (Sys.opaque_identity 0.0)) in
    let field_trim_length = ref (Obj.magic (Sys.opaque_identity 0.0)) in
    let bits0 = ref 0 in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg "out-of-bounds substring position or length";
          match len with
            | 11 -> (
                if String.unsafe_get s pos = 't' && String.unsafe_get s (pos+1) = 'r' && String.unsafe_get s (pos+2) = 'i' && String.unsafe_get s (pos+3) = 'm' && String.unsafe_get s (pos+4) = '_' && String.unsafe_get s (pos+5) = 'l' && String.unsafe_get s (pos+6) = 'e' && String.unsafe_get s (pos+7) = 'n' && String.unsafe_get s (pos+8) = 'g' && String.unsafe_get s (pos+9) = 't' && String.unsafe_get s (pos+10) = 'h' then (
                  2
                )
                else (
                  -1
                )
              )
            | 13 -> (
                if String.unsafe_get s pos = 't' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 'r' && String.unsafe_get s (pos+3) = 'g' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 't' && String.unsafe_get s (pos+6) = '_' && String.unsafe_get s (pos+7) = 'l' && String.unsafe_get s (pos+8) = 'e' && String.unsafe_get s (pos+9) = 'n' && String.unsafe_get s (pos+10) = 'g' && String.unsafe_get s (pos+11) = 't' && String.unsafe_get s (pos+12) = 'h' then (
                  1
                )
                else (
                  -1
                )
              )
            | 14 -> (
                if String.unsafe_get s pos = 'm' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 'x' && String.unsafe_get s (pos+3) = '_' && String.unsafe_get s (pos+4) = 'r' && String.unsafe_get s (pos+5) = 'e' && String.unsafe_get s (pos+6) = 'c' && String.unsafe_get s (pos+7) = 'o' && String.unsafe_get s (pos+8) = 'r' && String.unsafe_get s (pos+9) = 'd' && String.unsafe_get s (pos+10) = '_' && String.unsafe_get s (pos+11) = 'a' && String.unsafe_get s (pos+12) = 'g' && String.unsafe_get s (pos+13) = 'e' then (
                  0
                )
                else (
                  -1
                )
              )
            | _ -> (
                -1
              )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Ag_oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            field_max_record_age := (
              (
                Ag_oj_run.read_number
              ) p lb
            );
            bits0 := !bits0 lor 0x1;
          | 1 ->
            field_target_length := (
              (
                Ag_oj_run.read_int
              ) p lb
            );
            bits0 := !bits0 lor 0x2;
          | 2 ->
            field_trim_length := (
              (
                Ag_oj_run.read_int
              ) p lb
            );
            bits0 := !bits0 lor 0x4;
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg "out-of-bounds substring position or length";
            match len with
              | 11 -> (
                  if String.unsafe_get s pos = 't' && String.unsafe_get s (pos+1) = 'r' && String.unsafe_get s (pos+2) = 'i' && String.unsafe_get s (pos+3) = 'm' && String.unsafe_get s (pos+4) = '_' && String.unsafe_get s (pos+5) = 'l' && String.unsafe_get s (pos+6) = 'e' && String.unsafe_get s (pos+7) = 'n' && String.unsafe_get s (pos+8) = 'g' && String.unsafe_get s (pos+9) = 't' && String.unsafe_get s (pos+10) = 'h' then (
                    2
                  )
                  else (
                    -1
                  )
                )
              | 13 -> (
                  if String.unsafe_get s pos = 't' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 'r' && String.unsafe_get s (pos+3) = 'g' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 't' && String.unsafe_get s (pos+6) = '_' && String.unsafe_get s (pos+7) = 'l' && String.unsafe_get s (pos+8) = 'e' && String.unsafe_get s (pos+9) = 'n' && String.unsafe_get s (pos+10) = 'g' && String.unsafe_get s (pos+11) = 't' && String.unsafe_get s (pos+12) = 'h' then (
                    1
                  )
                  else (
                    -1
                  )
                )
              | 14 -> (
                  if String.unsafe_get s pos = 'm' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 'x' && String.unsafe_get s (pos+3) = '_' && String.unsafe_get s (pos+4) = 'r' && String.unsafe_get s (pos+5) = 'e' && String.unsafe_get s (pos+6) = 'c' && String.unsafe_get s (pos+7) = 'o' && String.unsafe_get s (pos+8) = 'r' && String.unsafe_get s (pos+9) = 'd' && String.unsafe_get s (pos+10) = '_' && String.unsafe_get s (pos+11) = 'a' && String.unsafe_get s (pos+12) = 'g' && String.unsafe_get s (pos+13) = 'e' then (
                    0
                  )
                  else (
                    -1
                  )
                )
              | _ -> (
                  -1
                )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Ag_oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              field_max_record_age := (
                (
                  Ag_oj_run.read_number
                ) p lb
              );
              bits0 := !bits0 lor 0x1;
            | 1 ->
              field_target_length := (
                (
                  Ag_oj_run.read_int
                ) p lb
              );
              bits0 := !bits0 lor 0x2;
            | 2 ->
              field_trim_length := (
                (
                  Ag_oj_run.read_int
                ) p lb
              );
              bits0 := !bits0 lor 0x4;
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        if !bits0 <> 0x7 then Ag_oj_run.missing_fields p [| !bits0 |] [| "max_record_age"; "target_length"; "trim_length" |];
        (
          {
            max_record_age = !field_max_record_age;
            target_length = !field_target_length;
            trim_length = !field_trim_length;
          }
         : cache)
      )
)
let cache_of_string s =
  read_cache (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write__2 = (
  Ag_oj_run.write_option (
    write_file
  )
)
let string_of__2 ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write__2 ob x;
  Bi_outbuf.contents ob
let read__2 = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    
    match Yojson.Safe.start_any_variant p lb with
      | `Edgy_bracket -> (
          Yojson.Safe.read_space p lb;
          let f =
            fun s pos len ->
              if pos < 0 || len < 0 || pos + len > String.length s then
                invalid_arg "out-of-bounds substring position or length";
              try
                if len = 4 then (
                  match String.unsafe_get s pos with
                    | 'N' -> (
                        if String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'n' && String.unsafe_get s (pos+3) = 'e' then (
                          0
                        )
                        else (
                          raise (Exit)
                        )
                      )
                    | 'S' -> (
                        if String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'm' && String.unsafe_get s (pos+3) = 'e' then (
                          1
                        )
                        else (
                          raise (Exit)
                        )
                      )
                    | _ -> (
                        raise (Exit)
                      )
                )
                else (
                  raise (Exit)
                )
              with Exit -> (
                  Ag_oj_run.invalid_variant_tag p (String.sub s pos len)
                )
          in
          let i = Yojson.Safe.map_ident p f lb in
          match i with
            | 0 ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              (None : _ option)
            | 1 ->
              Ag_oj_run.read_until_field_value p lb;
              let x = (
                  read_file
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              (Some x : _ option)
            | _ -> (
                assert false
              )
        )
      | `Double_quote -> (
          let f =
            fun s pos len ->
              if pos < 0 || len < 0 || pos + len > String.length s then
                invalid_arg "out-of-bounds substring position or length";
              try
                if len = 4 && String.unsafe_get s pos = 'N' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'n' && String.unsafe_get s (pos+3) = 'e' then (
                  0
                )
                else (
                  raise (Exit)
                )
              with Exit -> (
                  Ag_oj_run.invalid_variant_tag p (String.sub s pos len)
                )
          in
          let i = Yojson.Safe.map_string p f lb in
          match i with
            | 0 ->
              (None : _ option)
            | _ -> (
                assert false
              )
        )
      | `Square_bracket -> (
          Yojson.Safe.read_space p lb;
          let f =
            fun s pos len ->
              if pos < 0 || len < 0 || pos + len > String.length s then
                invalid_arg "out-of-bounds substring position or length";
              try
                if len = 4 && String.unsafe_get s pos = 'S' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'm' && String.unsafe_get s (pos+3) = 'e' then (
                  0
                )
                else (
                  raise (Exit)
                )
              with Exit -> (
                  Ag_oj_run.invalid_variant_tag p (String.sub s pos len)
                )
          in
          let i = Yojson.Safe.map_ident p f lb in
          match i with
            | 0 ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_comma p lb;
              Yojson.Safe.read_space p lb;
              let x = (
                  read_file
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_rbr p lb;
              (Some x : _ option)
            | _ -> (
                assert false
              )
        )
)
let _2_of_string s =
  read__2 (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write__1 = (
  Ag_oj_run.write_option (
    Yojson.Safe.write_string
  )
)
let string_of__1 ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write__1 ob x;
  Bi_outbuf.contents ob
let read__1 = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    
    match Yojson.Safe.start_any_variant p lb with
      | `Edgy_bracket -> (
          Yojson.Safe.read_space p lb;
          let f =
            fun s pos len ->
              if pos < 0 || len < 0 || pos + len > String.length s then
                invalid_arg "out-of-bounds substring position or length";
              try
                if len = 4 then (
                  match String.unsafe_get s pos with
                    | 'N' -> (
                        if String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'n' && String.unsafe_get s (pos+3) = 'e' then (
                          0
                        )
                        else (
                          raise (Exit)
                        )
                      )
                    | 'S' -> (
                        if String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'm' && String.unsafe_get s (pos+3) = 'e' then (
                          1
                        )
                        else (
                          raise (Exit)
                        )
                      )
                    | _ -> (
                        raise (Exit)
                      )
                )
                else (
                  raise (Exit)
                )
              with Exit -> (
                  Ag_oj_run.invalid_variant_tag p (String.sub s pos len)
                )
          in
          let i = Yojson.Safe.map_ident p f lb in
          match i with
            | 0 ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              (None : _ option)
            | 1 ->
              Ag_oj_run.read_until_field_value p lb;
              let x = (
                  Ag_oj_run.read_string
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              (Some x : _ option)
            | _ -> (
                assert false
              )
        )
      | `Double_quote -> (
          let f =
            fun s pos len ->
              if pos < 0 || len < 0 || pos + len > String.length s then
                invalid_arg "out-of-bounds substring position or length";
              try
                if len = 4 && String.unsafe_get s pos = 'N' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'n' && String.unsafe_get s (pos+3) = 'e' then (
                  0
                )
                else (
                  raise (Exit)
                )
              with Exit -> (
                  Ag_oj_run.invalid_variant_tag p (String.sub s pos len)
                )
          in
          let i = Yojson.Safe.map_string p f lb in
          match i with
            | 0 ->
              (None : _ option)
            | _ -> (
                assert false
              )
        )
      | `Square_bracket -> (
          Yojson.Safe.read_space p lb;
          let f =
            fun s pos len ->
              if pos < 0 || len < 0 || pos + len > String.length s then
                invalid_arg "out-of-bounds substring position or length";
              try
                if len = 4 && String.unsafe_get s pos = 'S' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'm' && String.unsafe_get s (pos+3) = 'e' then (
                  0
                )
                else (
                  raise (Exit)
                )
              with Exit -> (
                  Ag_oj_run.invalid_variant_tag p (String.sub s pos len)
                )
          in
          let i = Yojson.Safe.map_ident p f lb in
          match i with
            | 0 ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_comma p lb;
              Yojson.Safe.read_space p lb;
              let x = (
                  Ag_oj_run.read_string
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_rbr p lb;
              (Some x : _ option)
            | _ -> (
                assert false
              )
        )
)
let _1_of_string s =
  read__1 (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_t : _ -> t -> _ = (
  fun ob x ->
    Bi_outbuf.add_char ob '{';
    let is_first = ref true in
    if !is_first then
      is_first := false
    else
      Bi_outbuf.add_char ob ',';
    Bi_outbuf.add_string ob "\"port\":";
    (
      Yojson.Safe.write_int
    )
      ob x.port;
    if !is_first then
      is_first := false
    else
      Bi_outbuf.add_char ob ',';
    Bi_outbuf.add_string ob "\"database\":";
    (
      write_database
    )
      ob x.database;
    if !is_first then
      is_first := false
    else
      Bi_outbuf.add_char ob ',';
    Bi_outbuf.add_string ob "\"cache\":";
    (
      write_cache
    )
      ob x.cache;
    (match x.pathless_redirect_uri with None -> () | Some x ->
      if !is_first then
        is_first := false
      else
        Bi_outbuf.add_char ob ',';
      Bi_outbuf.add_string ob "\"pathless_redirect_uri\":";
      (
        Yojson.Safe.write_string
      )
        ob x;
    );
    (match x.error_404_page_path with None -> () | Some x ->
      if !is_first then
        is_first := false
      else
        Bi_outbuf.add_char ob ',';
      Bi_outbuf.add_string ob "\"error_404_page_path\":";
      (
        write_file
      )
        ob x;
    );
    (match x.error_50x_page_path with None -> () | Some x ->
      if !is_first then
        is_first := false
      else
        Bi_outbuf.add_char ob ',';
      Bi_outbuf.add_string ob "\"error_50x_page_path\":";
      (
        write_file
      )
        ob x;
    );
    Bi_outbuf.add_char ob '}';
)
let string_of_t ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write_t ob x;
  Bi_outbuf.contents ob
let read_t = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field_port = ref (Obj.magic (Sys.opaque_identity 0.0)) in
    let field_database = ref (Obj.magic (Sys.opaque_identity 0.0)) in
    let field_cache = ref (Obj.magic (Sys.opaque_identity 0.0)) in
    let field_pathless_redirect_uri = ref (None) in
    let field_error_404_page_path = ref (None) in
    let field_error_50x_page_path = ref (None) in
    let bits0 = ref 0 in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg "out-of-bounds substring position or length";
          match len with
            | 4 -> (
                if String.unsafe_get s pos = 'p' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'r' && String.unsafe_get s (pos+3) = 't' then (
                  0
                )
                else (
                  -1
                )
              )
            | 5 -> (
                if String.unsafe_get s pos = 'c' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 'c' && String.unsafe_get s (pos+3) = 'h' && String.unsafe_get s (pos+4) = 'e' then (
                  2
                )
                else (
                  -1
                )
              )
            | 8 -> (
                if String.unsafe_get s pos = 'd' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 't' && String.unsafe_get s (pos+3) = 'a' && String.unsafe_get s (pos+4) = 'b' && String.unsafe_get s (pos+5) = 'a' && String.unsafe_get s (pos+6) = 's' && String.unsafe_get s (pos+7) = 'e' then (
                  1
                )
                else (
                  -1
                )
              )
            | 19 -> (
                if String.unsafe_get s pos = 'e' && String.unsafe_get s (pos+1) = 'r' && String.unsafe_get s (pos+2) = 'r' && String.unsafe_get s (pos+3) = 'o' && String.unsafe_get s (pos+4) = 'r' && String.unsafe_get s (pos+5) = '_' then (
                  match String.unsafe_get s (pos+6) with
                    | '4' -> (
                        if String.unsafe_get s (pos+7) = '0' && String.unsafe_get s (pos+8) = '4' && String.unsafe_get s (pos+9) = '_' && String.unsafe_get s (pos+10) = 'p' && String.unsafe_get s (pos+11) = 'a' && String.unsafe_get s (pos+12) = 'g' && String.unsafe_get s (pos+13) = 'e' && String.unsafe_get s (pos+14) = '_' && String.unsafe_get s (pos+15) = 'p' && String.unsafe_get s (pos+16) = 'a' && String.unsafe_get s (pos+17) = 't' && String.unsafe_get s (pos+18) = 'h' then (
                          4
                        )
                        else (
                          -1
                        )
                      )
                    | '5' -> (
                        if String.unsafe_get s (pos+7) = '0' && String.unsafe_get s (pos+8) = 'x' && String.unsafe_get s (pos+9) = '_' && String.unsafe_get s (pos+10) = 'p' && String.unsafe_get s (pos+11) = 'a' && String.unsafe_get s (pos+12) = 'g' && String.unsafe_get s (pos+13) = 'e' && String.unsafe_get s (pos+14) = '_' && String.unsafe_get s (pos+15) = 'p' && String.unsafe_get s (pos+16) = 'a' && String.unsafe_get s (pos+17) = 't' && String.unsafe_get s (pos+18) = 'h' then (
                          5
                        )
                        else (
                          -1
                        )
                      )
                    | _ -> (
                        -1
                      )
                )
                else (
                  -1
                )
              )
            | 21 -> (
                if String.unsafe_get s pos = 'p' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 't' && String.unsafe_get s (pos+3) = 'h' && String.unsafe_get s (pos+4) = 'l' && String.unsafe_get s (pos+5) = 'e' && String.unsafe_get s (pos+6) = 's' && String.unsafe_get s (pos+7) = 's' && String.unsafe_get s (pos+8) = '_' && String.unsafe_get s (pos+9) = 'r' && String.unsafe_get s (pos+10) = 'e' && String.unsafe_get s (pos+11) = 'd' && String.unsafe_get s (pos+12) = 'i' && String.unsafe_get s (pos+13) = 'r' && String.unsafe_get s (pos+14) = 'e' && String.unsafe_get s (pos+15) = 'c' && String.unsafe_get s (pos+16) = 't' && String.unsafe_get s (pos+17) = '_' && String.unsafe_get s (pos+18) = 'u' && String.unsafe_get s (pos+19) = 'r' && String.unsafe_get s (pos+20) = 'i' then (
                  3
                )
                else (
                  -1
                )
              )
            | _ -> (
                -1
              )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Ag_oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            field_port := (
              (
                Ag_oj_run.read_int
              ) p lb
            );
            bits0 := !bits0 lor 0x1;
          | 1 ->
            field_database := (
              (
                read_database
              ) p lb
            );
            bits0 := !bits0 lor 0x2;
          | 2 ->
            field_cache := (
              (
                read_cache
              ) p lb
            );
            bits0 := !bits0 lor 0x4;
          | 3 ->
            if not (Yojson.Safe.read_null_if_possible p lb) then (
              field_pathless_redirect_uri := (
                Some (
                  (
                    Ag_oj_run.read_string
                  ) p lb
                )
              );
            )
          | 4 ->
            if not (Yojson.Safe.read_null_if_possible p lb) then (
              field_error_404_page_path := (
                Some (
                  (
                    read_file
                  ) p lb
                )
              );
            )
          | 5 ->
            if not (Yojson.Safe.read_null_if_possible p lb) then (
              field_error_50x_page_path := (
                Some (
                  (
                    read_file
                  ) p lb
                )
              );
            )
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg "out-of-bounds substring position or length";
            match len with
              | 4 -> (
                  if String.unsafe_get s pos = 'p' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'r' && String.unsafe_get s (pos+3) = 't' then (
                    0
                  )
                  else (
                    -1
                  )
                )
              | 5 -> (
                  if String.unsafe_get s pos = 'c' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 'c' && String.unsafe_get s (pos+3) = 'h' && String.unsafe_get s (pos+4) = 'e' then (
                    2
                  )
                  else (
                    -1
                  )
                )
              | 8 -> (
                  if String.unsafe_get s pos = 'd' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 't' && String.unsafe_get s (pos+3) = 'a' && String.unsafe_get s (pos+4) = 'b' && String.unsafe_get s (pos+5) = 'a' && String.unsafe_get s (pos+6) = 's' && String.unsafe_get s (pos+7) = 'e' then (
                    1
                  )
                  else (
                    -1
                  )
                )
              | 19 -> (
                  if String.unsafe_get s pos = 'e' && String.unsafe_get s (pos+1) = 'r' && String.unsafe_get s (pos+2) = 'r' && String.unsafe_get s (pos+3) = 'o' && String.unsafe_get s (pos+4) = 'r' && String.unsafe_get s (pos+5) = '_' then (
                    match String.unsafe_get s (pos+6) with
                      | '4' -> (
                          if String.unsafe_get s (pos+7) = '0' && String.unsafe_get s (pos+8) = '4' && String.unsafe_get s (pos+9) = '_' && String.unsafe_get s (pos+10) = 'p' && String.unsafe_get s (pos+11) = 'a' && String.unsafe_get s (pos+12) = 'g' && String.unsafe_get s (pos+13) = 'e' && String.unsafe_get s (pos+14) = '_' && String.unsafe_get s (pos+15) = 'p' && String.unsafe_get s (pos+16) = 'a' && String.unsafe_get s (pos+17) = 't' && String.unsafe_get s (pos+18) = 'h' then (
                            4
                          )
                          else (
                            -1
                          )
                        )
                      | '5' -> (
                          if String.unsafe_get s (pos+7) = '0' && String.unsafe_get s (pos+8) = 'x' && String.unsafe_get s (pos+9) = '_' && String.unsafe_get s (pos+10) = 'p' && String.unsafe_get s (pos+11) = 'a' && String.unsafe_get s (pos+12) = 'g' && String.unsafe_get s (pos+13) = 'e' && String.unsafe_get s (pos+14) = '_' && String.unsafe_get s (pos+15) = 'p' && String.unsafe_get s (pos+16) = 'a' && String.unsafe_get s (pos+17) = 't' && String.unsafe_get s (pos+18) = 'h' then (
                            5
                          )
                          else (
                            -1
                          )
                        )
                      | _ -> (
                          -1
                        )
                  )
                  else (
                    -1
                  )
                )
              | 21 -> (
                  if String.unsafe_get s pos = 'p' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 't' && String.unsafe_get s (pos+3) = 'h' && String.unsafe_get s (pos+4) = 'l' && String.unsafe_get s (pos+5) = 'e' && String.unsafe_get s (pos+6) = 's' && String.unsafe_get s (pos+7) = 's' && String.unsafe_get s (pos+8) = '_' && String.unsafe_get s (pos+9) = 'r' && String.unsafe_get s (pos+10) = 'e' && String.unsafe_get s (pos+11) = 'd' && String.unsafe_get s (pos+12) = 'i' && String.unsafe_get s (pos+13) = 'r' && String.unsafe_get s (pos+14) = 'e' && String.unsafe_get s (pos+15) = 'c' && String.unsafe_get s (pos+16) = 't' && String.unsafe_get s (pos+17) = '_' && String.unsafe_get s (pos+18) = 'u' && String.unsafe_get s (pos+19) = 'r' && String.unsafe_get s (pos+20) = 'i' then (
                    3
                  )
                  else (
                    -1
                  )
                )
              | _ -> (
                  -1
                )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Ag_oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              field_port := (
                (
                  Ag_oj_run.read_int
                ) p lb
              );
              bits0 := !bits0 lor 0x1;
            | 1 ->
              field_database := (
                (
                  read_database
                ) p lb
              );
              bits0 := !bits0 lor 0x2;
            | 2 ->
              field_cache := (
                (
                  read_cache
                ) p lb
              );
              bits0 := !bits0 lor 0x4;
            | 3 ->
              if not (Yojson.Safe.read_null_if_possible p lb) then (
                field_pathless_redirect_uri := (
                  Some (
                    (
                      Ag_oj_run.read_string
                    ) p lb
                  )
                );
              )
            | 4 ->
              if not (Yojson.Safe.read_null_if_possible p lb) then (
                field_error_404_page_path := (
                  Some (
                    (
                      read_file
                    ) p lb
                  )
                );
              )
            | 5 ->
              if not (Yojson.Safe.read_null_if_possible p lb) then (
                field_error_50x_page_path := (
                  Some (
                    (
                      read_file
                    ) p lb
                  )
                );
              )
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        if !bits0 <> 0x7 then Ag_oj_run.missing_fields p [| !bits0 |] [| "port"; "database"; "cache" |];
        (
          {
            port = !field_port;
            database = !field_database;
            cache = !field_cache;
            pathless_redirect_uri = !field_pathless_redirect_uri;
            error_404_page_path = !field_error_404_page_path;
            error_50x_page_path = !field_error_50x_page_path;
          }
         : t)
      )
)
let t_of_string s =
  read_t (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
