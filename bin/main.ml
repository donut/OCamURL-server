
open Lwt.Infix
open Printf

module Conf = Lib.Config

let () =
  Core.Command.run @@ Conf.CLI.start_service_command
  (fun service conf_path () ->
    match service with
    | "api" -> conf_path |> Conf.(of_file API.of_string) |> Api_server.start
    | x -> printf "There is no service [%s]\n" x)