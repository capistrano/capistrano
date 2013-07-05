# Capistrano 3.x Changelog

Reverse Chronological Order:

## `3.0.0.pre10`

 * Fixes pre9.

## `3.0.0.pre9`

 * Fixes a syntax error introduced with filtering (with tests) introduced in
   `pre8`. (@leehambley)

## `3.0.0.pre8`

 * Fixed a syntax where `roles(:foo, :bar)` was being mistaken as a filter
   (roles(:foo, :bar => nil). The correct syntax to use is: roles([:foo,:bar])
   (@leehambley)

## `3.0.0.pre7`

 * Fix Git https authentication. (@leehambley)
 * Capfile template fixes (repo/repo_url) (@teohm)
 * Readme Fixes (@ffmike, @kejadlen, @dwickwire)
 * Fix the positioning of the bundler hook, now immediately after finalize. (@teohm)
