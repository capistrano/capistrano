---
title: Installation
layout: default
---

Capistrano is bundled as a Ruby Gem. **It requires Ruby 1.9 or newer.**

Capistrano can be installed as a standalone Gem, or bundled into your
application.

<div class="alert">
It is recommended to fix the version number when using Capistrano, and is
therefore recommended to use an appropriate bundler.
</div>

### General Usage

The following commands will clone Capistrano at the latest `v3` revision, and
will build the gem and install it locally. **The Gem is not yet availalble via
Rubygems.org.**

{% highlight bash %}
$ git clone -b v3 https://github.com/capistrano/capistrano.git
$ cd capistrano
$ gem build *.gemspec
$ gem install *.gem
{% endhighlight %}

### Usage in a Rails project

Add the following lines to the Gemfile, to the group `:development` ideally.

{% highlight ruby %}
group :development do
  gem 'capistrano-rails', github: 'capistrano/capistrano-rails', branch: 'v3'
end
{% endhighlight %}

There will be a Gem released via [rubygems.org][rubygems], but as most people
are still using Capistrano v2.x, the v3 release will not be pushed to
[rubygems.org][rubygems] just yet give people a chance to lock their version
in their `Gemfile`.

The *Capistrano-Rails* Gem includes extras specifically designed for Ruby on
Rails, specifically:

 * Asset Pipeline Support
 * Gem Bundler Support
 * Database Migration Support

The documentation for these components can be found in
[their][capistrano-rails-asset-pipeline-readme],
[respective][capistrano-rails-gem-bundler-readme],
[READMEs][capistrano-rails-database-migrations-readme]. However for the most
part, to get the best, and most sensible results, simply `require` these
files:

{% highlight ruby %}
require 'capistrano/rails/assets'
require 'capistrano/rails/gem-bundler'
require 'capistrano/rails/database-migrations'
{% endhighlight %}

<div class="alert alert-info">
<h5>Help! I was using Capistrano `v2.x` and I didn't want to upgrade!</h5>

If you are using Capistrano `v2.x.x` and have also installed Capistrano `v3`
by mistake, then you can lock your Gem version for Capistrano at something
like:

{% highlight ruby %}
gem 'capistrano', '~> 2.15' # Or whatever patch release you are using
{% endhighlight %}

This is the [pessimistic operator][rubygems-pessimistic-operator] which
installs the closest matching version, at the time of writing this would
install `2.15.4`, and any other point-release in the `2.15.x` family without
the risk of accidentally upgrading to `v3`.
</div>

--
[rubygems]:                                    http://rubygems.org/
[rubygems-pessimistic-operator]:               http://docs.rubygems.org/read/chapter/16#page74
[capistrano-rails-asset-pipeline-readme]:      https://www.github.com/capistrano/asset-pipeline/bundler/README.md
[capistrano-rails-database-migrations-readme]: https://www.github.com/capistrano/migrations/bundler/README.md
[capistrano-rails-gem-bundler-readme]:         https://www.github.com/capistrano/capistrano-rails/bundler/README.md
