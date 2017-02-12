---
title: Installation
layout: default
---

Capistrano is bundled as a Ruby Gem. **It requires Ruby 2.0 or newer.**

Capistrano can be installed as a standalone Gem, or bundled into your
application.

<p class="alert-box alert">
It is recommended to fix the version number when using Capistrano, and is
therefore recommended to use an appropriate bundler.
</p>

### General Usage

The following command will install the latest released capistrano `v3` revision:

```bash
$ gem install capistrano
```

Or grab the bleeding edge head from:

```bash
$ git clone https://github.com/capistrano/capistrano.git
$ cd capistrano
$ gem build *.gemspec
$ gem install *.gem
```

### Usage in a Rails project

Add the following lines to the Gemfile:

```ruby
group :development do
  gem 'capistrano-rails', '~> 1.1'
end
```

The `capistrano-rails` gem includes extras specifically designed for Ruby on
Rails, specifically:

 * Asset Pipeline Support
 * Database Migration Support

The documentation for these components can be found in
[their][capistrano-rails-asset-pipeline-readme],
[respective][capistrano-rails-gem-bundler-readme],
[READMEs][capistrano-rails-database-migrations-readme]. However for the most
part, to get the best, and most sensible results, simply `require` in
Capfile, after the `require 'capistrano/deploy'` line:

```ruby
require 'capistrano/rails'
```

##### SSH

Capistrano deploys using SSH. Thus, you must be able to SSH (ideally with keys
and ssh-agent) from the deployment system to the destination system for
Capistrano to work.

You can test this using a ssh client, e.g. `ssh myuser@destinationserver`. If
you cannot connect at all, you may need to set up the SSH server or resolve
firewall/network issues. Look for a tutorial (here are suggestions for
[Ubuntu](https://help.ubuntu.com/community/SSH) and
[RedHat/CentOS](http://www.cyberciti.biz/faq/centos-ssh/)).

If a password is requested when you log in, you may need to set up SSH keys.
GitHub has a [good tutorial](https://help.github.com/articles/generating-ssh-keys/)
on creating these (follow steps 1 through 3). You will need to add your public
key to `~/.ssh/authorized_keys` on the destination server as the deployment user
(append on a new line).

More information on SSH and login is available via the
[Authentication and Authorisation](http://capistranorb.com/documentation/getting-started/authentication-and-authorisation/)
section of the guide.

If you are still struggling to get login working, try the
[Capistrano SSH Doctor](https://github.com/capistrano-plugins/capistrano-ssh-doctor)
plugin.

##### Help! I was using Capistrano `v2.x` and I didn't want to upgrade!

If you are using Capistrano `v2.x.x` and have also installed Capistrano `v3`
by mistake, then you can lock your Gem version for Capistrano at something
like:

```ruby
gem 'capistrano', '~> 2.15' # Or whatever patch release you are using
```

This is the [pessimistic operator][rubygems-pessimistic-operator] which
installs the closest matching version, at the time of writing this would
install `2.15.4`, and any other point-release in the `2.15.x` family without
the risk of accidentally upgrading to `v3`.


[rubygems]:                                    http://rubygems.org/
[rubygems-pessimistic-operator]:               http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[capistrano-rails-asset-pipeline-readme]:      https://github.com/capistrano/rails/blob/master/README.md
[capistrano-rails-database-migrations-readme]: https://github.com/capistrano/rails/blob/master/README.md
[capistrano-rails-gem-bundler-readme]:         https://github.com/capistrano/bundler/blob/master/README.md
