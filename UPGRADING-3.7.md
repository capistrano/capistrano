# Capistrano 3.7.0 upgrade guide

Capistrano 3.7.0 has not yet been released. This guide serves as a preview of
what is *planned* for 3.7.0, so that you can be prepared to update your
Capistrano deployment if necessary once it becomes available.

If you wish to try the new 3.7.0 behavior today, you can do so by using the
`master` branch in your Gemfile:

```ruby
gem "capistrano", :github => "capistrano/capistrano"
```

## The :scm variable is deprecated

Up until now, Capistrano's SCM was configured using the `:scm` variable:

```ruby
# This is now deprecated
set :scm, :svn
```

To avoid deprecation warnings:

1. Remove `set :scm, ...` from your Capistrano configuration.
2. Add *one* of the following SCM declarations to your `Capfile`:

```ruby
# To use Git
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# To use Mercurial
require "capistrano/scm/hg"
install_plugin Capistrano::SCM::Hg

# To use Subversion
require "capistrano/scm/svn"
install_plugin Capistrano::SCM::Svn
```

## This is the last release where Git is the automatic default

If you do not specify an SCM, Capistrano assumes Git. However this behavior is
now deprecated. Add this to your Capfile to avoid deprecation warnings:

```ruby
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git
```

## :git_strategy, :hg_strategy, and :svn_strategy are removed

Capistrano 3.7.0 has a rewritten SCM system that relies on "plugins". This
system is more flexible than the old "strategy" system that only allowed certain
parts of SCM tasks to be customized.

If your deployment relies on a custom SCM strategy, you will need to rewrite
that strategy to be a full-fledged SCM plugin instead. There is a fairly
straightforward migration path: write your plugin to be a subclass of the
built-in SCM that you want to customize. For example:

```ruby
require "capistrano/scm/git"

class MyCustomGit < Capistrano::SCM::Git
  # Override the methods you wish to customize, e.g.:
  def clone_repo
    # ...
  end
end
```

Then use your plugin in by loading it in the Capfile:

```ruby
require_relative "path/to/my_custom_git.rb"
install_plugin MyCustomGit
```

## Existing third-party SCMs are deprecated

If you are using a third-party SCM, you can continue using it without
changes, but you will see deprecation warnings. Contact the maintainer of the
third-party SCM gem and ask them about modifying the gem to work with the new
Capistrano 3.7.0 SCM plugin system.

## remote_file is removed

The `remote_file` method is no longer in Capistrano 3.7.0. You can read the
discussion that led to its removal here:
[issue 762](https://github.com/capistrano/capistrano/issues/762).

There is no direct replacement. To migrate to 3.7.0, you will need to rewrite
any parts of your deployment that use `remote_file` to use a different
mechanism for uploading files. Consider using the `upload!` method directly in
a procedural fashion instead.
