# Capistrano 3.x Changelog

Reverse Chronological Order:

## master

https://github.com/capistrano/capistrano/compare/v3.2.1...HEAD

* Pushing again to trigger another build (I have a seemingly random build fail) (@townsen)
* Enhancements (@townsen)
  * Deep copy properties added using the 'roles' keyword
  * If a property exists on a server when another definition is
    encountered and is an Array, Set or Hash then add the new values

    This allows roles to specify properties common to all servers and
    then for individual servers to modify them, keeping things DRY

Breaking Changes:
  * By using Ruby's noecho method introduced in Ruby version 1.9.3, we dropped support for Ruby versions prior to 1.9.3. See [issue #878](https://github.com/capistrano/capistrano/issues/878) and [PR #1112](https://github.com/capistrano/capistrano/pull/1112) for more information. (@kaikuchn)

* Bug Fixes:
  * Fixed compatibility with FreeBSD tar (@robbertkl)

* Minor Changes
  * Capistrano now allows to customize `local_user` for revision log. (@sauliusgrigaitis)
  * Added tests for after/before hooks features (@juanibiapina, @miry)
  * Improved the output of `cap --help`. (@mbrictson)
  * Cucumber suite now runs on the latest version of Vagrant (@tpett)
  * The `ask` method now supports the `echo: false` option. (@mbrictson, @kaikuchn)

## `3.2.1`

https://github.com/capistrano/capistrano/compare/v3.2.0...v3.2.1

* Bug Fixes:
  * 3.2.0 introduced some behaviour to modify the way before/after hooks were called, to allow the optional
    preservation of arguments to be passed to tasks. This release reverts that commit in order to restore
    original functionality, and fix (fairly serious) bugs introduced by the refactoring.

* Minor changes:
  * Update dsl#local_user method and add test for it. (@bruno-)
  * Revert short sha1 revision with git. (@blaugueux)
  * Changed asking question to more standard format (like common unix commandline tools) (@sponomarev)
  * Fixed typos in the README. (@sponomarev)
  * Added `keys` method to Configuration to allow introspection of configuration options. (@juanibiapina)

## `3.2.0`

The changelog entries here are incomplete, because many authors choose not to
be credited for their work, check the tag comparison link for Github.

https://github.com/capistrano/capistrano/compare/v3.1.0...v3.2.0

* Minor changes:
  * Added `keys` method to Server properties to allow introspection of automatically added
    properties.
  * Compatibility with Rake 10.2.0 - `ensure_task` is now added to `@top_level_tasks` as a string. (@dmarkow)
  * Amended the git check command, "ls-remote", to use "-h", limiting the list to refs/heads

## `3.1.0`

https://github.com/capistrano/capistrano/compare/v3.0.1...v3.1.0

Breaking changes:

  * `deploy:restart` task **is no longer run by default**.
    From this version, developers who restart the app on each deploy need to declare it in their deploy flow (eg `after 'deploy:publishing', 'deploy:restart'`).

    Please, check https://github.com/capistrano/capistrano/commit/4e6523e1f50707499cf75eb53dce37a89528a9b0 for more information. (@kirs)

* Minor changes
  * Tasks that used `linked_dirs` and `linked_files` now run on all roles, not just app roles (@mikespokefire)
  * Tasks `deploy:linked_dirs`, `deploy:make_linked_dirs`, `deploy:linked_files`, `deploy:cleanup_rollback`,
    `deploy:log_revision` and `deploy:revert_release` now use `release_roles()` not `roles()` meaning that they
    will only run on servers where the `no_release` property is not falsy. (@leehambley)
  * Fixed bug when `deploy:cleanup` was executed twice by default (@kirs)
  * Config location can now be changed with `deploy_config_path` and `stage_config_path` options (@seenmyfate)
  * `no_release` option is now available (@seenmyfate)
  * Raise an error if developer tries to define `:all` role, which is reserved (@kirs)
  * `deploy:failed` hook was added to add some custom behaviour on failed deploy (@seenmyfate)
  * Correctly infer namespace in task enhancements (@seenmyfate)
  * Add SHA to revision log (@blackxored)
  * Allow configuration of multiple servers with same hostname but different ports (@rsslldnphy)
  * Add command line option to control role filtering (@andytinycat)
  * Make use of recent changes in Rake to over-ride the application name (@shime)
  * Readme corrections (@nathanstitt)
  * Allow roles to be fetched with a variable containing an array (@seenmyfate)
  * Improve console (@jage)
  * Add ability to filter tasks to specific servers (host filtering). (@andytinycat)
  * Add a command line option to control role filter (`--roles`) (@andytinycat)
  * Use an SCM object with a pluggable strategy (@coffeeaddict)

Big thanks to @Kriechi for his help.

## `3.0.1`

https://github.com/capistrano/capistrano/compare/v3.0.0...v3.0.1

  * `capify` not listed as executable (@leehambley)
  * Confirm license as MIT (@leehambley)
  * Move the git ssh helper to application path (@mpapis)

## `3.0.0`

https://github.com/capistrano/capistrano/compare/2.15.5...v3.0.0

If you are coming here to wonder why your Capfile doesn't work anymore, please
vendor lock your Capistrano at 2.x, whichever version was working for you
until today.

Capistrano 3 is a ground-up rewrite with modularity, stability, speed and
future proofing in mind. It's a big change, but now the code is 10x smaller,
runs faster, is easier to read, and quicker to extend. In the reduction we've
come up with a great gem based modular system for plugins and we're really
proud of this release.

The 3.0.0 release contains 38 patches from the following amazing people:

  * Tom `seenmyfate` Clements: more than 28 patches including cucumber integration tests! Not to
    mention Rails asset pipeline code, and bundler integrations.
  * Lee Hambley: Small changes around compatibility and log formatting
  * Kir Shatrov: for improvements in the core to make it easier to write extensions, for
    improving documentation, and for effectively building the chruby, rvm and rbenv integrations.
  * Michael Nikitochkin: Fixing a bug around linked files and directories.
  * Jack Thorne: for improvements to the default `Capfile` to fix some bad example syntax.
  * Erik Hetzner: for (what looks like great) work on the Mercurial (Hg) support. The Hg and Git
    source control mechanisms do not work the same way, but rather lean on the strengths of the
    underlying tools.

    (If I missed anyone, I'm sorry, your contributions have been awesome)

The 2.x branch of code is now no longer maintained. Towards the end of it's
useful life there were an increasing number of features and pieces of code
which didn't make sense for certain groups of people, in certain situations,
leading a to a ping-pong tennis effect with pull requests every few weeks
"fixing" a use-case which had already been "fixed" shortly before. As many of
the use-cases are outside the scope of the testing environments I (and by
extension the trusted contributors and IRC regulars) were able to test for.

There's a more extensive post about my failure to be able to keep up with the
demands of maintaining v2 whilst trying to build something which is appropriate
for the current landscape. If you are affected by the unsupported 2 branch,
please contact me (Lee Hambley) to discuss how my company can help support you.
Otherwise, please try v3, we're sure you'll like it, and the code is designed
to be so simple that anyone can work on it.

## `3.0.0.pre14`

 * Thanks to numerous contributors, in particular (@teohm) for a series of improvements.

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
