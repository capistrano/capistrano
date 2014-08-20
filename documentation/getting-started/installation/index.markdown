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

The following command will install the latest released capistrano `v3` revision:

{% highlight bash %}
    $ gem install capistrano
{% endhighlight %}

Or grab the bleeding edge head from:

{% highlight bash %}
    $ git clone https://github.com/capistrano/capistrano.git
    $ cd capistrano
    $ gem build *.gemspec
    $ gem install *.gem
{% endhighlight %}

### Usage in a Rails project

Add the following lines to the Gemfile:

{% highlight ruby %}
    group :development do
      gem 'capistrano-rails', '~> 1.1.1'
    end
{% endhighlight %}

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

{% highlight ruby %}
    require 'capistrano/rails'
{% endhighlight %}


##### Help! I was using Capistrano `v2.x` and I didn't want to upgrade!

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


--
[rubygems]:                                    http://rubygems.org/
[rubygems-pessimistic-operator]:               http://docs.rubygems.org/read/chapter/16#page74
[capistrano-rails-asset-pipeline-readme]:      https://github.com/capistrano/rails/blob/master/README.md
[capistrano-rails-database-migrations-readme]: https://github.com/capistrano/rails/blob/master/README.md
[capistrano-rails-gem-bundler-readme]:         https://github.com/capistrano/bundler/blob/master/README.md
