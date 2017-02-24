---
title: Preparing Your Application
layout: default
---

<p class="alert-box">
  This will focus on preparing a Rails application, but most ideas expressed
  here have parallels in Python, or PHP applications
</p>

### 1. Commit your application to some externally available source control hosting provider.

If you are not doing so already, you should host your code somewhere with a
provider such as GitHub, BitBucket, Codeplane, or repositoryhosting.com.

Capistrano currently supports Git, Mercurial, and SVN out of the box.
There might be 3<sup>rd</sup> party plugins adding support for various other systems.

### 2. Move secrets out of the repository.

<p class="alert-box alert">
If you've accidentally committed state secrets to the repository, you might
want to take
<a href="https://help.github.com/articles/remove-sensitive-data">special steps</a>
to erase them from the repository history for all time.
</p>

Ideally one should remove `config/database.yml` to something like
`config/database.yml.example`. You and your team should copy the example file
into place on their development machines, under Capistrano. This leaves the
`database.yml` filename unused so that we can symlink the production database
configuration into place at deploy time.

The original `database.yml` should be added to the `.gitignore` (or your SCM's
parallel concept of ignored files)

```bash
$ cp config/database.yml{,.example}
$ echo config/database.yml >> .gitignore
```

This should be done for any other secret files, we'll create the production
version of the file when we deploy, and symlink it into place.

### 3. Initialize Capistrano in your application.

```bash
$ cd my-project
$ cap install
```

This will create a bunch of files, the important ones are:

```bash
├── Capfile
├── config
│   ├── deploy
│   │   ├── production.rb
│   │   └── staging.rb
│   └── deploy.rb
└── lib
    └── capistrano
            └── tasks
```

Your new Capfile will automatically include any tasks from any `*.rake` files
in `lib/capistrano/tasks`.


### 4. Configure your server addresses in the generated files.

We'll just work with the staging environment here, so you can pretend that
`config/deploy/production.rb` doesn't exist, for the most part that's your
business.

Capistrano breaks down common tasks into a notion of *roles*, that is, taking
a typical Rails application that we have roughly speaking three roles, `web`,
`app`, and `db`.

The three roles can be confusing, as the boundary of web and app servers is a bit blurry if, for example,
using [Passenger](https://www.phusionpassenger.com/) with Apache, which in effect embeds your app server in the
web server (embeds Passenger in the Apache process itself). Confusingly,
Passenger can also be used in modes where this isn't true, so we'll ignore
that for the time being. If you know the difference (i.e you are using
nginx as your web server, and puma/unicorn, or similar for your app server,
that should be fine), then we can assume that they're the same, which is pretty
common.

The example file generated will look something like this:

```ruby
set :stage, :staging

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, %w{example.com}
role :web, %w{example.com}
role :db,  %w{example.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# is something that quacks like a hash and can be used
# to set extended properties on the server.
server 'example.com', roles: %w{web app}, my_property: :my_value

# set :rails_env, :staging
```

Servers can be defined in two ways, implicitly using the simple `role` syntax and
explicitly using the extended `server` syntax.  Both result in one or more servers for
each role being defined. The `app` and `db` roles are just placeholders, if you are using
the `capistrano/rails-*` addons (more on that later) then they have a meaning, but if you
are deploying something simpler, feel free to delete them if they're meaningless to you.

Both types can specify optional _properties_ to be associated with a server or role. These
properties include Capistrano-required ones such as the SSH options (username, port, keys
etc.) and also arbitrary custom properties.  They are there in case people want to build the
server list more comprehensively from something like the *EC2* command line tools, and
want to use the extended properties for something that makes sense in their environment.

The following shows defining two servers: one where we set the
username, and another where we set the port.  These host strings are parsed and expanded
out in to the equivalent of the server line after the comment:

```ruby
# using simple syntax
role :web, %w{hello@world.com example.com:1234}

# using extended syntax (which is equivalent)
server 'world.com', roles: [:web], user: 'hello'
server 'example.com', roles: [:web], port: 1234
```

<p class="alert-box"> You can define a server or role using both syntaxes and the
properties will be merged. See the Properties Documentation for details
</p>

<p class="alert-box alert"> If you define servers with either the simple or the extended
syntax and explicitly specify a user or a port number, the last definition will win. This
is identical behaviour to scalar custom properties. In older versions of Capistrano,
<b>multiple</b> servers were created and the merging was ill-defined. </p>

### 5. Set the shared information in `deploy.rb`.

The `deploy.rb` is a place where the configuration common to each environment
can be specified, normally the *repository URL* and the *user as whom to
deploy* are specified here.

The generated sample file starts with the following, and is followed by a few
self-documenting, commented-out configuration options, feel free to play with
them a little:

```ruby
  set :application, 'my_app_name'
  set :repo_url, 'git@example.com:me/my_repo.git'
  ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
```

Here we'd set the name of the application, ideally in a way that's safe for
filenames on your target operating system.

Second we set the repository URL, and this *MUST* be somewhere that the server we
are deploying to can reach.

Here's how this might look in a typical example: note that we'll cover
authentication in the next chapter, but for now we'll assume this repository is
open source, taking an example application from the [Rails Examples and
Tutorials](http://railsapps.github.io/) site. There we'll find maintained a
handful of typical Rails apps with typical dependencies.

The Rails application they host, which uses Devise (for authentication) and
Cancan (for authorisation) along side Twitter Bootstrap for assets has been
forked to the Capistrano repository, but you can find the (unchanged) original
[here](https://github.com/RailsApps/rails3-bootstrap-devise-cancan).

```ruby
  set :application, 'rails3-bootstrap-devise-cancan-demo'
  set :repo_url, 'https://github.com/capistrano/rails3-bootstrap-devise-cancan'
  set :branch, 'master'
```

I've simplified the `:branch` variable to simply be a `set` variable, and not a
question prompt, as this repository only has a master branch.

## Roundup

**At this point Capistrano knows where to find our servers, and where to find
our code.**

We've not covered how we authorise our servers to check out our code (there
are three pretty good ways of doing that with Git), nor have we determined how
to authorise Capistrano on our servers yet.
