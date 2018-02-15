# OCamURL Server #

A URL shortener sever written in OCaml with a GraphQL API. Check out [the web client][ocurl-client].

[ocurl-client]: https://github.com/rightthisminute/ocamurl-client

## Why OCaml ##

Throughout development and after release, a few have asked why I chose OCaml over ReasonML since both can be transpiled to JavaScript and the client is written in Reason. Some of it is practical: I learned about OCaml before Reason and even once I knew of Reason, I didn't know it could be compiled to a native binary until later. And at the point, I found that BuckleScript isn't compatible with OCaml > 4.02.3, but both `ocaml-mariadb` and `ocaml-garphql-server` require 4.05.0 or greater. 

All of that said, I still prefer OCaml's syntax over Reason, and when it makes sense, I foresee continuing to use OCaml when I'm not planning on compiling to JS, and possibly even in those situations if I don't have a need for React.

## Installation & Setup ##

This has been tested on macOS High Sierra and Ubuntu 16.04.

### [`ocaml-mariadb`][ocaml-mariadb]'s Dependencies ###

Follow [the offical instructions][mdb-deps]. For Ubuntu 16.04, I had to configure MariaDB's own repositories. The required libraries weren't avialable by default. Instructions for that are on the linked page.

[ocaml-mariadb]: https://github.com/andrenth/ocaml-mariadb
[mdb-deps]: https://github.com/andrenth/ocaml-mariadb/tree/1.0.1#installation

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

```
$ find . -iname '*.atd' -exec atdgen -t '{}' \; -exec atdgen -j '{}' \;
$ jbuilder build bin/main.exe
```

The first command finds all the config definition files and transpiles them to OCaml. The second builds the actual application.

### Database Setup ###

Run [/db/schema.sql] on the database to add the required tables. Be sure to setup the database details in your config files (see examples in [/config/]).

### Running ###

There are two services available. The first is the API and the second is the redirect server. Both need configuration files. You can see examples in the [/config] directory.

The application takes two arguments, first is the name of the service (`api` or `alias-redirect`) and the second is the path to the appropriate config file.

```
$ ./_build/default/bin/main.exe api config/api.json
$ ./_build/default/bin/main.exe alias-redirect config/alias-redirect.json
```

The API server listens to GraphQL requests on the path [/graphql]. The [GraphiQL][] UI is also available at that path.

[GraphiQL]: https://github.com/graphql/graphiql

## Areas for Improvement ##

This was my first project in OCaml and so likely has a lot of room for improvement. 

### Code Deduplication ###

There is basically no utilization of functors. The first place I'd start looking  to use them is the query and mutation modules (*_qry.ml and *.mut.ml files). There are likely other places as well, but nothing else major comes to mind as of writing.

### GraphQL Error Handling ###

The [GraphQL server library][] being used [does not have a good way to handle errors with data][graphql-errors-issue]. To get around this I [changed the schema][my-solution] to have results like `PayloadOrError` that are basically `{ error: Error, payload: SomePayload }`, completely sidestepping the usual GraphQL error pathway. With this, it's on the client to handle this irregular method. There are probbably [better ways][better-solution] to handle it as it is, and I suspect that `ocaml-graphql-server` will come out with better error handling sooner than later. Whatever the case, there is a need for rework here.

[GraphQL server library]: https://github.com/andreas/ocaml-graphql-server
[graphql-errors-issue]: https://github.com/andreas/ocaml-graphql-server/issues/61
[my-solution]: https://github.com/andreas/ocaml-graphql-server/issues/61#issuecomment-337018266
[better-solution]: https://github.com/andreas/ocaml-graphql-server/issues/61#issuecomment-338508074

### Compliation and Installation Setup ###

The .install and .opam files need to be setup correctly.

## Known Issues ##

### Parameter count mismatch ###
`Lib.Schema.Generate_alias_mut.insert_alias_with_unique_name` sometimes runs into
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

This is a project for use at RightThisMinute. There is no promise of support or continued work in this public repo. It is being released mainly to benefit those who are starting out in OCaml. It's likely a poor example, but being simpler may help make some things clear. This isn't to say we're not accepting issues and pull requests, just know that we may have selfish motivations in what we integrate.