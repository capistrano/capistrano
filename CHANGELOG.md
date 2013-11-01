# Capistrano 3.x Changelog

Reverse Chronological Order:

## `3.0.1` (Not yet released)

  * capify' not listed as executable (@leehambley)
  * Confirm license as MIT (@leehambley)
  * Move the git ssh helper to application path (@mpapis)

## `3.0.0`

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
please contact me (Lee Hambley) to dicsuss how my company can help support you.
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
