---
title: Version Locking
layout: default
---

Capistrano will, by default, include a `lock` command at the top of `deploy.rb`. This checks that the version of Capistrano running the configuration is the same as was intended to run it.

The reasoning for this is that, in a pre-Bundler world, or when Bundler is not being used, Capistrano could behave in an unexpected and unclear manner with an incompatible configuration. Even today, it is easy to run Capistrano without `bundle exec` or a binstub (`bin/cap`, obtained through `bundle binstub capistrano`), resulting in unexpected behavior.

The syntax for the lock is the same as that used by Bundler in a Gemfile (see the Implementation section below).

The simplest form is: `lock '3.9.0'`. This locks the configuration to the exact version given.

The most useful form uses the pessimistic operator: `~> 3.9.0`. This allows the version of the last segment to be increased, and all prior segments are locked. For example, if you used `lock '~> 3.9.2'`, version `3.9.3` would be allowed, but `3.9.1`, `3.10.0`, and `4.0.0` would not. Generally, you will want to lock to the `major.minor` revision. This means that the major version cannot increase, but the minor version can, which is consistent with semantic versioning (which Capistrano follows, [loosely](https://github.com/capistrano/capistrano/pull/1894/files)).

You can also use `>`, `<`, `<=`, `>=`, and `=` before the version, as in `lock '>= 3.9.0'`. These are useful if you want to lock to a specific set of rules.

For more complex usage, you can combine operators. For example, you can write `lock ['>= 3.9.0', '< 3.9.10']`, which would allow everything from 3.9.0 to 3.9.9, but not 3.9.10 or greater.

## Implementation

The code reuses RubyGems core [version comparison logic](https://ruby-doc.org/stdlib-2.4.2/libdoc/rubygems/rdoc/Gem/Dependency.html#method-i-3D-7E). So anything you can do in RubyGems, you can do here.
