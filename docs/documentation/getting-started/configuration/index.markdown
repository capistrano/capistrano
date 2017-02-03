---
title: Configuration
layout: default
---

## Location

Configuration variables can be either global or specific to your stage.

* global
  * `config/deploy.rb`
* stage specific
  * `config/deploy/<stage_name>.rb`

## Access

Each variable can be set to a specific value:

```ruby
set :application, 'MyLittleApplication'

# use a lambda to delay evaluation
set :special_thing, -> { "SomeThing_#{fetch :other_config}" }
```

A value can be retrieved from the configuration at any time:

```ruby
fetch :application
# => "MyLittleApplication"

fetch(:special_thing, 'some_default_value')
# will return the value if set, or the second argument as default value
```

**New in Capistrano 3.5:** for a variable that holds an Array, easily add values to it using `append`. This comes in especially handy for `:linked_dirs` and `:linked_files` (see Variables reference below).

```ruby
append :linked_dirs, ".bundle", "tmp"
```

The inverse is also available: `remove` will strive to drop an entry from an array. This comes in handy if you have a shared configuration which sets an array but a specific config doesn't need one of the elements.

```ruby
remove :linked_dirs, ".bundle", "tmp"
```

## Variables

The following variables are settable:

* `:application`
  * The name of the application.

* `:deploy_to`
  * **default:** `-> { "/var/www/#{fetch(:application)}" }`
  * The path on the remote server where the application should be deployed.
  * If application contains whitespace or such this path might be invalid. See Structure for the exact directories used.

* `:scm`
  * **default:** `:git`
  * The Source Control Management used.
  * Currently :git, :hg and :svn are supported. Plugins might add additional ones.

* `:repo_url`
  * URL to the repository.
  * Must be a valid URL for the used SCM.
  * Example: `set :repo_url, 'git@example.com:me/my_repo.git'` for a git repo located in /home/git/me
  * Hint #1: to access a repo on a machine using a non-standard ssh port: `set :repo_url, 'ssh://git@example.com:30000/~/me/my_repo.git'`
  * Hint #2: when using :svn and branches, declare the repo_url like this: `set :repo_url, -> { "svn://myhost/myrepo/#{fetch(:branch)}" }`
  * Warning: if you move your repository to a new URL when using an SCM other than Git and change this variable, already deployed remote servers won't reflect this change automatically, you have to manually re-configure the repository on the remote servers (in path determined by `:repo_path`) or delete it (`rm -rf repo` in the default setup) and let Capistrano recreate it on the next deploy using the updated URL.

* `:branch`
  * **default:** `'master'`
  * The branch name to be deployed from SCM.

* `:svn_username`
  * When using :svn, provides the username for authentication.

* `:svn_password`
  * When using :svn, provides the password for authentication.

* `:svn_revision`
  * **New in version 3.5**
  * When using :svn, set the specific revision number you want to deploy.

* `:repo_path`
  * **default:** `-> { "#{fetch(:deploy_to)}/repo" }`
  * The path on the remote server where the repository should be placed.
  * This does not normally need to be set

* `:repo_tree`
  * **default:** None. The whole repository is normally deployed.
  * The subtree of the repository to deploy.
  * Currently only implemented for Git and Hg.

* `:linked_files`
  * **default:** `[]`
  * Listed files will be symlinked from the shared folder of the application into each release directory during deployment.
  * Can be used for persistent configuration files like `database.yml`. See Structure for the exact directories.

* `:linked_dirs`
  * **default:** `[]`
  * Listed directories will be symlinked into the release directory during deployment.
  * Can be used for persistent directories like uploads or other data. See Structure for the exact directories.

* `:default_env`
  * **default:** `{}`
  * Default shell environment used during command execution.
  * Can be used to set or manipulate specific environment variables (e.g. `$PATH` and such).

* `:keep_releases`
  * **default:** `5`
  * The last `n` releases are kept for possible rollbacks.
  * The cleanup task detects outdated release folders and removes them if needed.

* `:tmp_dir`
  * **default:** `'/tmp'`
  * Temporary directory used during deployments to store data.
  * If you have a shared web host, this setting may need to be set (e.g. /home/user/tmp/capistrano).

* `:local_user`
  * **default:** `-> { Etc.getlogin }`
  * Username of the local machine used to update the revision log.

* `:pty`
  * **default:** `false`
  * Used in SSHKit.

* `:log_level`
  * **default:** `:debug`
  * Used in SSHKit.

* `:format`
  * **default:** `:airbrussh`
  * Used in SSHKit.


Capistrano plugins can provide their own configuration variables. Please refer
to the plugin documentation for the specifics. Plugins are allowed to add or
manipulate default values as well as already user-defined values after the
plugin is loaded.
