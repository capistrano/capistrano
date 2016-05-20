# Upgrading Capistrano

From time to time Capistrano will introduce changes and new features that may
break existing projects. This document describes how to upgrade your project in
case you are affected by these changes.

## 3.5.x -> master

### SCM Changes

Capistrano is moving to a new system for choosing and customizing the SCM used
in your deployments
(see [#1572](https://github.com/capistrano/capistrano/pull/1572)).
In a nutshell, this means:

* The `set :scm, ...` mechanism is deprecated in favor of a plugin system
  described below.
* In a future release, no SCM will be loaded by default. To prepare your
  project, you should explicitly load the Git SCM.

To upgrade your project, edit your Capfile to specify the SCM you are using,
like this:

```ruby
# Add *one* of the following to your Capfile

# If your project uses Git:
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# If your project uses Subversion:
require "capistrano/scm/svn"
install_plugin Capistrano::SCM::Svn

# If your project uses Mercurial:
require "capistrano/scm/hg"
install_plugin Capistrano::SCM::Hg
```

Then **remove** any `set :scm, ...` line from your `deploy.rb`:

```ruby
# REMOVE THIS
set :scm, :git
```

**If you are using a third-party SCM,** you can continue using it without
changes, but you will see deprecation warnings. Contact the maintainer of the
third-party SCM gem and ask them about modifying the gem to work with the new
Capistrano SCM plugin system.
