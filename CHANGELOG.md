# Capistrano 3.x Changelog

Reverse Chronological Order:

## `3.0.0.pre13`

 * Fixed typos in the Capfile. (@teohm)
 * Allow setting SSH options globally. (@korin)
 * Change the flow (and hooks) see http://www.capistranorb.com/documentation/getting-started/flow/ for more information. Requires min SSHKit 0.0.34 (@teohm)
 * Fix sorting releases in lexicographical order (@teohm)

## `3.0.0.pre12`

 * `capistrano/bundler` now runs bundle on all roles, this addresses the same
   issue as the related changes in `pre11`. (@leehambley)

## `3.0.0.pre11`

 * Some deploy.rake tasks now apply to all servers, not expecting a
   primary(:app) server which may not exist in all deploy environments.
   (@leehambley).

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
