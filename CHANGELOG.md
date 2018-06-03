# Capistrano 3.x Changelog

All notable changes to this project will be documented in this file, in reverse chronological order.

**Capistrano follows a modified version of [SemVer](http://semver.org)**, similar to the Ruby on Rails project. For a `X.Y.Z` release:

* `Z` indicates bug fixes only; no breaking changes and no new features, except as necessary for security fixes.
* `Y` is bumped when we add new features. Occasionally a `Y` release may include small breaking changes. We will notify via CHANGELOG entries and/or deprecation notices if there are breaking changes.
* `X` is incremented for significant breaking changes. This is reserved for special occasions, like a complete rewrite.

**Capistrano uses a six-week release cadence.** Every six weeks, give or take, any changes in master will be published as a new rubygems version. If you'd like to use a feature or fix that is in master and you can't wait for the next planned release, put this in your project's Gemfile to use the master branch directly:

```ruby
gem "capistrano", github: "capistrano/capistrano", require: false
```

## [master]

[master]: https://github.com/capistrano/capistrano/compare/v3.11.0...HEAD

* Your contribution here!

## [`3.11.0`] (2018-06-02)

* [#1972](https://github.com/capistrano/capistrano/pull/1972): fallback ask to default when used in non interactive session

[`3.11.0`]: https://github.com/capistrano/capistrano/compare/v3.10.2...v3.11.0

## [`3.10.2`] (2018-04-15)

[`3.10.2`]: https://github.com/capistrano/capistrano/compare/v3.10.1...v3.10.2

### Breaking changes:

* None

### Fixes:

* [#1977](https://github.com/capistrano/capistrano/pull/1977): Remove append operator when writing the git file - [@mmiller1](https://github.com/mmiller1)

## [`3.10.1`] (2017-12-08)

[`3.10.1`]: https://github.com/capistrano/capistrano/compare/v3.10.0...v3.10.1

### Breaking changes:

* None

### Fixes:

* [#1954](https://github.com/capistrano/capistrano/pull/1954): Fix Host filtering when multi-host strings contain `0`

## [`3.10.0`] (2017-10-23)

[`3.10.0`]: https://github.com/capistrano/capistrano/compare/v3.9.1...v3.10.0

As of this release, version 2.x of Capistrano is officially End of Life. No further releases of 2.x series are planned, and pull requests against 2.x are no longer accepted. The maintainers encourage you to upgrade to 3.x if possible.

### Breaking changes:

* None

### New features:

* [#1943](https://github.com/capistrano/capistrano/issues/1943): Make 'releases' and 'shared' directory names configurable from deployment target
* [#1922](https://github.com/capistrano/capistrano/pull/1922): Prevents last good release from being deleted during cleanup if there are too many subsequent failed deploys
* [#1930](https://github.com/capistrano/capistrano/issues/1930): Default to locking the version using the pessimistic version operator at the patch level.

### Fixes:

* [#1937](https://github.com/capistrano/capistrano/pull/1937): Clarify error message when plugin is required in the wrong config file.

## [`3.9.1`] (2017-09-08)

[`3.9.1`]: https://github.com/capistrano/capistrano/compare/v3.9.0...v3.9.1

### Breaking changes:

* None

### Fixes:

* [#1912](https://github.com/capistrano/capistrano/pull/1912): Fixed an issue where questions posed by `ask` were not printed on certain platforms - [@kminiatures](https://github.com/kminiatures)

## [`3.9.0`] (2017-07-28)

[`3.9.0`]: https://github.com/capistrano/capistrano/compare/v3.8.2...v3.9.0

### Breaking changes:

* None

### New features:

* [#1911](https://github.com/capistrano/capistrano/pull/1911): Add Capistrano::DSL#invoke! for repetitive tasks

### Fixes:

* [#1899](https://github.com/capistrano/capistrano/pull/1899): Updated `deploy:cleanup` to continue rotating the releases and skip the invalid directory names instead of skipping the whole rotation of releases. The warning message has changed slightly due to the change of behavior.

## [`3.8.2`] (2017-06-16)

[`3.8.2`]: https://github.com/capistrano/capistrano/compare/v3.8.1...v3.8.2

### Breaking changes:

* None

### Other changes:

* [#1882](https://github.com/capistrano/capistrano/pull/1882): Explain where to add new Capfile lines in scm deprecation warning - [@robd](https://github.com/robd)

## [`3.8.1`] (2017-04-21)

[`3.8.1`]: https://github.com/capistrano/capistrano/compare/v3.8.0...v3.8.1

### Breaking changes:

* None

### Fixes:

* [#1867](https://github.com/capistrano/capistrano/pull/1867): Allow `cap -T` to run without Capfile present - [@mattbrictson](https://github.com/mattbrictson)

## [`3.8.0`] (2017-03-10)

[`3.8.0`]: https://github.com/capistrano/capistrano/compare/v3.7.2...v3.8.0

### Minor breaking changes:

* [#1846](https://github.com/capistrano/capistrano/pull/1846): add_host - When this method has already been called once for a given host and it is called a second time with a port, a new host will be added. Previously, the first host would have been updated. [(@dbenamy)](https://github.com/dbenamy)

### New features:

* [#1860](https://github.com/capistrano/capistrano/pull/1860): Allow cap to be run within subdir and still work - [@mattbrictson](https://github.com/mattbrictson)

### Fixes:

* [#1835](https://github.com/capistrano/capistrano/pull/1835): Stopped printing parenthesis in ask prompt if no default or nil was passed as argument [(@chamini2)](https://github.com/chamini2)
* [#1840](https://github.com/capistrano/capistrano/pull/1840): Git plugin: shellescape git_wrapper_path [(@olleolleolle)](https://github.com/olleolleolle)
* [#1843](https://github.com/capistrano/capistrano/pull/1843): Properly shell escape git:wrapper steps - [@mattbrictson](https://github.com/mattbrictson)
* [#1846](https://github.com/capistrano/capistrano/pull/1846): Defining a role is now O(hosts) instead of O(hosts^2) [(@dbenamy)](https://github.com/dbenamy)
* Run `svn switch` to work with svn branches if repo_url is changed
* [#1856](https://github.com/capistrano/capistrano/pull/1856): Fix hg repo_tree implementation - [@mattbrictson](https://github.com/mattbrictson)
* [#1857](https://github.com/capistrano/capistrano/pull/1857): Don't emit doctor warning when repo_tree is set - [@mattbrictson](https://github.com/mattbrictson)

### Other changes:

* [capistrano-harrow#4](https://github.com/harrowio/capistrano-harrow/issues/4): Drop dependency on `capistrano-harrow` gem. Gem can still be installed separately [(@leehambley)](https://github.com/leehambley)
* [#1859](https://github.com/capistrano/capistrano/pull/1859): Move git-specific repo_url logic into git plugin - [@mattbrictson](https://github.com/mattbrictson)
* [#1858](https://github.com/capistrano/capistrano/pull/1858): Unset the :scm variable when an SCM plugin is used - [@mattbrictson](https://github.com/mattbrictson)

## [`3.7.2`] (2017-01-27)

[`3.7.2`]: https://github.com/capistrano/capistrano/compare/v3.7.1...v3.7.2

### Potentially breaking changes:

* None

### Other changes:

* Suppress log messages of `git ls-remote` by filtering remote refs (@aeroastro)
* The Git SCM now allows the repo_url to be changed without manually wiping out the mirror on each target host first (@javanthropus)

## [`3.7.1`] (2016-12-16)

[`3.7.1`]: https://github.com/capistrano/capistrano/compare/v3.7.0...v3.7.1

### Potentially breaking changes:

* None

### Fixes:

* Fixed a bug with mercurial deploys failing due to an undefined variable

## [`3.7.0`] (2016-12-10)

[`3.7.0`]: https://github.com/capistrano/capistrano/compare/v3.6.1...v3.7.0

*Note: These release notes include all changes since 3.6.1, including the changes that were first published in 3.7.0.beta1.*

### Deprecations:

* The `set :scm, ...` mechanism is now deprecated in favor of a new SCM plugin system. See the [UPGRADING-3.7](UPGRADING-3.7.md) document for details

### Potentially breaking changes:

* The `:git_strategy`, `:hg_strategy`, and `:svn_strategy` settings have been removed with no replacement. If you have been using these to customize Capistrano's SCM behavior, you will need to rewrite your customization using the [new plugin system](http://capistranorb.com/documentation/advanced-features/custom-scm/)
* `remote_file` feature has been removed and is no longer available to use @SaiVardhan

### New features:

* The `tar` used by the Git SCM now honors the SSHKit command map, allowing an alternative tar binary to be used (e.g. gtar) #1787 (@caius)
* Add support for custom on-filters [#1776](https://github.com/capistrano/capistrano/issues/1776)

### Fixes:

* Fix test suite to work with Mocha 1.2.0 (@caius)
* Fix bug where host_filter and role_filter were overly greedy [#1766](https://github.com/capistrano/capistrano/issues/1766) (@cseeger-epages)
* Fix the removal of old releases `deploy:cleanup`. Logic is changed because of unreliable modification times on folders. Removal of directories is now decided by sorting on folder names (name is generated from current datetime format YmdHis). Cleanup is skipped, and a warning is given when a folder name is in a different format

## [`3.7.0.beta1`] (2016-11-02)

[`3.7.0.beta1`]: https://github.com/capistrano/capistrano/compare/v3.6.1...v3.7.0.beta1

### Deprecations:

* The `set :scm, ...` mechanism is now deprecated in favor of a new SCM plugin
system. See the [UPGRADING-3.7](UPGRADING-3.7.md) document for details.

### Potentially breaking changes:

* The `:git_strategy`, `:hg_strategy`, and `:svn_strategy` settings have been
removed with no replacement. If you have been using these to customize
Capistrano's SCM behavior, you will need to rewrite your customization using
the [new plugin system](http://capistranorb.com/documentation/advanced-features/custom-scm/).
* `remote_file` feature has been removed and is no longer available to use @SaiVardhan

### New features:

* The `tar` used by the Git SCM now honors the SSHKit command map, allowing an alternative tar binary to be used (e.g. gtar) #1787 (@caius)

### Fixes:

* Fix test suite to work with Mocha 1.2.0 (@caius)
* Fix bug where host_filter and role_filter were overly greedy [#1766](https://github.com/capistrano/capistrano/issues/1766) (@cseeger-epages)

## [`3.6.1`] (2016-08-23)

[`3.6.1`]: https://github.com/capistrano/capistrano/compare/v3.6.0...v3.6.1

### Fixes:

* Restore compatibility with older versions of Rake (< 11.0.0) (@troelskn)
* Fix `NoMethodError: undefined method gsub` when setting `:application` to a Proc. The original fix released in 3.6.0 worked for values specified with blocks, but not for those specified with procs or lambdas (the latter syntax is much more common). [#1681](https://github.com/capistrano/capistrano/issues/1681)
* Fix a bug where deploy would fail if `:local_user` contained a space; spaces are now replaced with dashes when computing the git-ssh suffix. (@will_in_wi)

## [`3.6.0`] (2016-07-26)

[`3.6.0`]: https://github.com/capistrano/capistrano/compare/v3.5.0...v3.6.0

Thank you to the many first-time contributors from the Capistrano community who
helped with this release!

### Deprecations:

  * Deprecate `remote_file` feature (will be removed in Capistrano 3.7.0) (@lebedev-yury)
  * Deprecate `:git_strategy`, `:hg_strategy`, and `:svn_strategy` variables.
    These will be completely removed in 3.7.0.
  * Added warning about future deprecation of reinvocation behaviour (@troelskn)

Refer to the [Capistrano 3.7.0 upgrade document](UPGRADING-3.7.md) if you are
affected by these deprecations.

### New features:

  * Added a `doctor:servers` subtask that outputs a summary of servers, roles & properties (@irvingwashington)
  * Make path to git wrapper script configurable (@thickpaddy)
  * Make name of current directory configurable via configuration variable `:current_directory` (@websi)
  * It is now possible to rollback to a specific release using the
    `ROLLBACK_RELEASE` environment variable.
    [#1155](https://github.com/capistrano/capistrano/issues/1155) (@lanrion)

### Fixes:

  * `doctor` no longer erroneously warns that `:git_strategy` and other SCM options are "unrecognized" (@shanesaww)
  * Fix `NoMethodError: undefined method gsub` when setting `:application` to a
    Proc. [#1681](https://github.com/capistrano/capistrano/issues/1681)
    (@mattbrictson)

### Other changes:

  * Raise a better error when an ‘after’ hook isn’t found (@jdelStrother)
  * Change git wrapper path to work better with multiple users (@thickpaddy)
  * Restrict the uploaded git wrapper script permissions to 700 (@irvingwashington)
  * Add `net-ssh` gem version to `doctor:gems` output (@lebedev-yury)

## [`3.5.0`]

[`3.5.0`]: https://github.com/capistrano/capistrano/compare/v3.4.1...v3.5.0

**You'll notice a big cosmetic change in this release: the default logging
format has been changed to
[Airbrussh](https://github.com/mattbrictson/airbrussh).** For more details on
what Airbrussh does
and how to configure it, visit the
[Airbrussh README](https://github.com/mattbrictson/airbrussh#readme).

* To opt out of the new format, simply add `set :format, :pretty` to switch to
  the old default of Capistrano 3.4.0 and earlier.
* If you are already an Airbrussh user, note that the default configuration has
  changed, and the syntax for configuring Airbrussh has changed as well.
  [This simple upgrade guide](https://github.com/mattbrictson/airbrussh/blob/master/UPGRADING-CAP-3.5.md)
  will walk you through it.

### Potentially breaking changes:

* Drop support for Ruby 1.9.3 (Capistrano does no longer work with 1.9.3)
* Git version 1.6.3 or greater is now required
* Remove 'vendor/bundle' from default :linked_dirs (@ojab)
* Old versions of SSHKit (before 1.9.0) are no longer supported
* SHA1 hash of current git revision written to REVISION file is no longer abbreviated
* Ensure task invocation within after hooks is namespace aware, which may require
  you to change how your `after` hooks are declared in some cases; see
  [#1652](https://github.com/capistrano/capistrano/issues/1652) for an example
  and how to correct it (@thickpaddy)
* Validation of the `:application` variable forbids special characters such as slash,
  this may be a breaking change in case that you rely on using a `/` in your application
  name to deploy from a sub directory.

### New features:

* Added a `doctor` task that outputs helpful troubleshooting information. Try it like this: `cap production doctor`. (@mattbrictson)
* Added a `dry_run?` helper method
* `remove` DSL method for removing values like from arrays like `linked_dirs`
* `append` DSL method for pushing values like `linked_dirs`
  [#1447](https://github.com/capistrano/capistrano/pull/1447),
  [#1586](https://github.com/capistrano/capistrano/pull/1586)
* Added support for git shallow clone
* Added new runtime option `--print-config-variables` that inspect all defined config variables in order to assist development of new capistrano tasks (@gerardo-navarro)
* Prune dead tracking branches from git repositories while updating
* Added options to set username and password when using Subversion as SCM (@dsthode)
* Allow after() to refer to tasks that have not been loaded yet (@jcoglan)
* Allow use "all" as string for server filtering (@theist)
* Print a warning and abort if "load:defaults" is erroneously invoked after
  capistrano is already loaded, e.g. when a plugin is loaded in `deploy.rb`
  instead of `Capfile`. (@mattbrictson)
* Added option to set specific revision when using Subversion as SCM (@marcovtwout)
* Deduplicate list of linked directories
* Integration with Harrow.io (See http://capistranorb.com/documentation/harrow/) when running `cap install`
* Added validate method to DSL to allow validation of certain values (@Kriechi)
    * validate values before assignment inside of `set(:key, value)`
    * should raise a `Capistrano::ValidationError` if invalid
* Added default validation for Capistrano-specific variables (@Kriechi)

### Fixes:

* Capistrano is now fully-compatible with Rake 11.0. (@mattbrictson)
* Fix filtering behaviour when using literal hostnames in on() block (@townsen)
* Allow dot in :application name (@marcovtwout)
* Fixed git-ssh permission error (@spight)

### Other changes:

* Internal Rubocop cleanups.
* Removed the post-install message (@Kriechi)
* Refactor `Configuration::Filter` to use filtering strategies instead
  of case statements (@cshaffer)
* Clean up rubocop lint warnings (@cshaffer)

## [`3.4.0`]

[`3.4.0`]: https://github.com/capistrano/capistrano/compare/v3.3.5...v3.4.0

* Fixed fetch revision for annotated git tags. (@igorsokolov)
* Fixed updating roles when custom user or port is specified. (@ayastreb)
* Disables statistics collection.

* `bin/` is not suggested to be in `linked_dirs` anymore (@kirs)
  * bin/ is often checked out into repo
  * https://github.com/capistrano/bundler/issues/45#issuecomment-69349237

* Bugfix:
  * release_roles did not honour additional property filtering (@townsen)
  * Refactored and simplified property filtering code (@townsen)

* Breaking Changes
  * Hosts with the same name are now consolidated into one irrespective of the
    user and port. This allows multiple declarations of a server to be made safely.
    The last declared properties will win. See capistranorb.com Properties documentation
    for details.
  * Inside the on() block the host variable is now a copy of the host, so changes can be
    made within the block (such as dynamically overriding the user) that will not persist.
    This is very convenient for switching the SSH user temporarily to 'root' for example.

* Minor changes
  * Add role_properties() method (see capistrano.github.io PR for doc) (@townsen)
  * Add equality syntax ( eg. port: 1234) for property filtering (@townsen)
  * Add documentation regarding property filtering (@townsen)
  * Clarify wording and recommendation in stage template. (@Kriechi)
    * Both available syntaxes provide similar functionality, do not use both for the same server+role combination.
  * Allow specification of repo_path using stage variable
    default is as before (@townsen)

## [`3.3.5`]

[`3.3.5`]: https://github.com/capistrano/capistrano/compare/v3.3.4...v3.3.5

* Fixed setting properties twice when creating new server. See [issue
  #1214](https://github.com/capistrano/capistrano/issues/1214) (@ayastreb)

## [`3.3.4`]

[`3.3.4`]: https://github.com/capistrano/capistrano/compare/v3.3.3...v3.3.4

* Minor changes:
  * Rely on a newer version of capistrano-stats with better privacy (@leehambley)
  * Fix cucumber spec for loading tasks from stage configs (@sponomarev)
  * Minor documentation fixes (@deeeki, @seuros, @andresilveira)
  * Spec improvements (@dimitrid, @sponomarev)
  * Fix to CLI flags for git-ls-remote (@dimitrid)

## [`3.3.3`]

[`3.3.3`]: https://github.com/capistrano/capistrano/compare/v3.2.1...v3.3.3

* Enhancement (@townsen)
  * Added the variable `:repo_tree` which allows the specification of a sub-tree that
    will be extracted from the repository. This is useful when deploying a project
    that lives in a subdirectory of a larger repository.
    Implemented only for git and hg.
    If not defined then the behaviour is as previously and the whole repository is
    extracted (subject to git-archive `.gitattributes` of course).

* Enhancement (@townsen): Remove unnecessary entries from default backtrace

    When the `--backtrace` (or `--trace`) command line option is not supplied
    Rake lowers the noise level in exception backtraces by building
    a regular expression containing all the system library paths and
    using it to exclude backtrace entries that match.

    This does not always go far enough, particularly in RVM environments when
    many gem paths are added. This commit reverses that approach and _only_
    include backtrace entries that fall within the Capfile and list of tasks
    imported thereafter. This makes reading exceptions much easier on the eye.

    If the full unexpurgated backtrace is required then the --backtrace
    and --trace options supply it as before.

* Disable loading stages configs on `cap -T` (@sponomarev)

* Enhancements (@townsen)
  * Fix matching on hosts with custom ports or users set
  * Previously filtering would affect any generated configuration files so that
    files newly deployed would not be the same as those on the hosts previously
    deployed (and now excluded by filters). This is almost certainly not what is
    wanted: the filters should apply only to the on() method and thus any
    configuration files deployed will be identical across the set of servers
    making up the stage.
  * Host and Role filtering now affects only `on()` commands
    and not the `roles()`, `release_roles()` and `primary()` methods.
  * This applies to filters defined via the command line, the environment
    and the :filter variable.
  * Filtering now supports Regular expressions
  * This change _could_ cause existing scripts that use filtering and depend on
    the old behaviour to fail, though it is unlikely. Users who rely on
    filtering should check that generated configuration files are correct, and
    where not introduce server properties to do the filtering. For example, if a
    filter was used to specify an active subset of servers (by hostname), it should
    be removed and replaced with an 'active' property (set to true or false) on the
    server definitions. This keeps the stage file as the canonical model of the
    deployment environment.

  * See the documentation in the README.md file

* Enhancements (@townsen)
  * Added set_if_empty method to DSL to allow conditional setting
  * Altered standard Capistrano defaults so that they are not set
    at the start of a stage if they have been previously set. This
    allows variables like :default_env to be set in deploy.rb.
  * Deep copy properties added using the 'roles' keyword
  * If a property exists on a server when another definition is
    encountered and is an Array, Set or Hash then add the new values

    This allows roles to specify properties common to all servers and
    then for individual servers to modify them, keeping things DRY

Breaking Changes:
  * By using Ruby's noecho method introduced in Ruby version 1.9.3, we dropped support for Ruby versions prior to 1.9.3. See [issue #878](https://github.com/capistrano/capistrano/issues/878) and [PR #1112](https://github.com/capistrano/capistrano/pull/1112) for more information. (@kaikuchn)
  * Track (anonymous) statistics, see https://github.com/capistrano/stats. This breaks automated deployment on continuous integration servers until the `.capistrano/metrics` file is created (with content `full` to simulate a "yes") via the interactive prompt or manually.

* Bug Fixes:
  * Fixed compatibility with FreeBSD tar (@robbertkl)
  * remote_file can be used inside a namespace (@mikz)

* Minor Changes
  * Remove -v flag from mkdir call. (@caligo-mentis)
  * Capistrano now allows to customize `local_user` for revision log. (@sauliusgrigaitis)
  * Added tests for after/before hooks features (@juanibiapina, @miry)
  * Added `--force` flag to `svn export` command to fix errors when the release directory already exists.
  * Improved the output of `cap --help`. (@mbrictson)
  * Cucumber suite now runs on the latest version of Vagrant (@tpett)
  * The `ask` method now supports the `echo: false` option. (@mbrictson, @kaikuchn)
  * Cucumber scenario improvements (@bruno-)
  * Added suggestion to Capfile to use 'capistrano-passenger' gem, replacing suggestion in config/deploy.rb to re-implement 'deploy:restart' (@betesh)
  * Updated svn fetch_revision method to use `svnversion`
  * `cap install` no longer overwrites existing files. (@dmarkow)

## [`3.2.1`]

[`3.2.1`]: https://github.com/capistrano/capistrano/compare/v3.2.0...v3.2.1

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
  * Improve error message when git:check fails (raise instead of silently `exit 1`) (@mbrictson)

## [`3.2.0`]

The changelog entries here are incomplete, because many authors choose not to
be credited for their work, check the tag comparison link for Github.

[`3.2.0`]: https://github.com/capistrano/capistrano/compare/v3.1.0...v3.2.0

* Minor changes:
  * Added `keys` method to Server properties to allow introspection of automatically added
    properties.
  * Compatibility with Rake 10.2.0 - `ensure_task` is now added to `@top_level_tasks` as a string. (@dmarkow)
  * Amended the git check command, "ls-remote", to use "-h", limiting the list to refs/heads

## [`3.1.0`]

[`3.1.0`]: https://github.com/capistrano/capistrano/compare/v3.0.1...v3.1.0

Breaking changes:

  * `deploy:restart` task **is no longer run by default**.
    From this version, developers who restart the app on each deploy need to declare it in their deploy flow (eg `after 'deploy:publishing', 'deploy:restart'`)
    or, for passenger applications, use the capistrano-passenger gem.

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

## [`3.0.1`]

[`3.0.1`]: https://github.com/capistrano/capistrano/compare/v3.0.0...v3.0.1

  * `capify` not listed as executable (@leehambley)
  * Confirm license as MIT (@leehambley)
  * Move the git ssh helper to application path (@mpapis)

## [`3.0.0`]

[`3.0.0`]: https://github.com/capistrano/capistrano/compare/2.15.5...v3.0.0

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
