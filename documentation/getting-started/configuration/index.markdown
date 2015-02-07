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
set :application, -> { "SomeThing_#{fetch :other_config}" }
```


A value can be retrieved from the configuration at any time:

```ruby
fetch :application
# => "MyLittleApplication"

fetch(:special_thing, 'some_default_value')
# will return the value if set, or the second argument as default value
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
  * Listed files will be symlinked into each release directory during deployment.
  * Can be used for persistent configuration files like `database.yml`. See Structure for the exact directorys.

* `:linked_dirs`
  * **default:** `[]`
  * Listed directories will be symlinked into the release directory during deployment.
  * Can be used for persistent directories like uploads or other data. See Structure for the exact directorys.

* `:default_env`
  * **default:** `{}`
  * Default shell environment used during command execution.
  * Can be used to set or manipulate specific environment variables (e.g. `$PATH` and such).

* `:branch`
  * **default:** `'master'`
  * The branch name to be deployed from SCM.

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
  * **default:** `:pretty`
  * Used in SSHKit.


Capistrano plugins can provide their own configuration variables. Please refer
to the plugin documentation for the specifics. Plugins are allowed to add or
manipulate default values as well as already user-defined values after the
plugin is loaded.
