
open Lwt.Infix
open Printf

module Conf = Lib.Config

let () =
  Core.Command.run @@ Conf.CLI.start_service_command
  (fun service conf_path () ->
    let parse to_conf = Conf.of_file conf_path to_conf in
    match service with
    | "alias-redirect" ->
        Alias_redirect.start @@ parse Conf.Alias_redirect.of_string
    | "api" ->
        Api_server.start @@ parse Conf.API.of_string
    | x -> printf "There is no service [%s]\n" x)