# OCamURL Server #

A URL shortener sever written in OCaml with a GraphQL API.

## Installation & Setup ##

This has been tested on macOS High Sierra and Ubuntu 16.04.

### [ocaml-mariadb][]'s Dependencies ###

Follow [the offical instructions][mdb-deps]. For Ubuntu 16.04, I had to configure MariaDB's own repositories. The required libraries weren't avialable by default.

[ocaml-mariadb]: https://github.com/andrenth/ocaml-mariadb
[mdb-deps]: https://github.com/andrenth/ocaml-mariadb/tree/1.0.1#installation

### OCaml Dependencies ###

On Ubuntu, I needed to install these packages via `apt-get`:

* `software-properties-common`
* `libffi-dev`
* `m4`

Then I just used `brew install opam` on macOS and `apt-get install opam` on Ubuntu. 

### Project Dependencies ###

These are the `opam` libraries this project depends on:

* `ocaml` v4.05.0
* `atdgen`
* `cohttp-lwt-unix`
* `core`
* `graphql-lwt`
* `jbuilder`
* `lwt`
* `mariadb`
* `re`
* `uri`
* `yojson`

### Building ###

Basically just used these commands:

```
$ find . -iname '*.atd' -exec atdgen -t '{}' \; -exec atdgen -j '{}' \;
$ jbuilder build bin/main.exe
```

The first finds all the config definition files and compiles them. The second builds the actual application.

### Database Setup ###

[/db/schema.sql] describes the tables and relationships expeted to be in the database. Running this against the database should work fine. Be sure to setup the database details in your config files (see examples in [/config/]).

### Running ###

There are two services available from the built binary. The first is the API and the second is the redirect server. Both need configuration files passed as they run. You can see examples in the [/config] directory.

The application takes two arguments, first is the name of the service (`api` or `alias-redirect`) and the second is a path the appropriate config file.

```
$ ./_build/default/bin/main.exe api config/api.json
$ ./_build/default/bin/main.exe alias-redirect config/alias-redirect.json
```

The API server listens to GraphQL request on the path [/graphql].

## Areas for Improvement ##

This was my first project in OCaml and so likely has a lot of room for improvement. 

### Duplicated Code ###

There is basically no utilization of functors. The first place I'd start looking for to use them is the query and mutation modules (*_qry.ml and *.mut.ml). There are likely other places as well, but nothing else major comes to mind as of writing.

### GraphQL Error Handling ###

The [GraphQL server library][] being used has [does not have a good way to handle errors with data][graphql-errors-issue]. To get around this I [changed the schema][my-solution] to have results like `PayloadOrError` that are basically `{ error: Error, payload: SomePayload }` and its on the client to check which has a value. There are probbably [better ways][better-solution] to handle it as is, and I suspect that this library will come out with better error handling sooner than later. Whatever the case, there is a need for reworking here.

[GraphQL server library]: https://github.com/andreas/ocaml-graphql-server
[graphql-errors-issue]: https://github.com/andreas/ocaml-graphql-server/issues/61
[my-solution]: https://github.com/andreas/ocaml-graphql-server/issues/61#issuecomment-337018266
[better-solution]: https://github.com/andreas/ocaml-graphql-server/issues/61#issuecomment-338508074

### Compliation and Installation Setup ###

The .install and .opam files need to be setup correctly. I haven't had time to look into how to set those up properly.



## Known Issues ##

### Parameter count mismatch ###
In `Lib.Schema.Generate_alias_mut.insert_alias_with_unique_name` runs into
an error when trying to insert a duplicate name:
  
> Failure "exec: (0) parameter count mismatch"

I'm not sure exactly what causes it, but if in `generate_name` of the same
module has `Unix.gettimeofday` changed to `Unix.time` and the `generateAlias`
endpoint is queried many times, very quickly (maybe within a second,
before `Unix.time` returns something different than the previous query)
this error shows up.

I've tried reproducing it in a context outside of this GraphQL app, but have
not had success yet.

## Project Expectations ##

This is a project for use in production at RightThisMinute. There is no promise of support or continued work in this public repo. It is being released mainly to benefit those who are starting out in OCaml. It's likely a poor example, but being simpler may help make some things clear.