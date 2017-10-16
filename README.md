
### Dependency Notes ###

[`ocaml-mariadb`][mdb] v8.1 has [a bug][mdb-int-issue] that causes `INT` MariaDB fields with `NULL` values to be returned at `` `Int 0`` instead of `` `Null``. Be sure to use a version that includes [this commit][mdb-int-issue-commit]. I used

```fish
opam pin add mariadb https://github.com/andrenth/ocaml-mariadb.git#bb35e58c2742d56dea843a7060ccc949da609278
```

[mdb]: https://github.com/andrenth/ocaml-mariadb/issues/10
[mdb-int-issue]: https://github.com/andrenth/ocaml-mariadb/issues/10
[mdb-int-issue-commit]: https://github.com/andrenth/ocaml-mariadb/commit/bb35e58c2742d56dea843a7060ccc949da609278