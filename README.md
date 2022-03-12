
# Capistrano: A deployment automation tool built on Ruby, Rake, and SSH.

[![Gem Version](https://badge.fury.io/rb/capistrano.svg)](http://badge.fury.io/rb/capistrano) [![Build Status](https://circleci.com/gh/capistrano/capistrano/tree/master.svg?style=shield)](https://app.circleci.com/pipelines/github/capistrano/capistrano?branch=master) [![Code Climate](https://codeclimate.com/github/capistrano/capistrano/badges/gpa.svg)](https://codeclimate.com/github/capistrano/capistrano) [![CodersClan](https://img.shields.io/badge/get-support-blue.svg)](http://codersclan.net/?repo_id=325&source=small)

Capistrano is a framework for building automated deployment scripts. Although Capistrano itself is written in Ruby, it can easily be used to deploy projects of any language or framework, be it Rails, Java, or PHP.

Once installed, Capistrano gives you a `cap` tool to perform your deployments from the comfort of your command line.

```
$ cd my-capistrano-enabled-project
$ cap production deploy
```

When you run `cap`, Capistrano dutifully connects to your server(s) via SSH and executes the steps necessary to deploy your project. You can define those steps yourself by writing [Rake](https://github.com/ruby/rake) tasks, or by using pre-built task libraries provided by the Capistrano community.

Tasks are simple to make. Here's an example:

```ruby
task :restart_sidekiq do
  on roles(:worker) do
    execute :service, "sidekiq restart"
  end
end
after "deploy:published", "restart_sidekiq"
```

*Note: This documentation is for the current version of Capistrano (3.x). If you are looking for Capistrano 2.x documentation, you can find it in [this archive](https://github.com/capistrano/capistrano-2.x-docs).*

---

## Contents

* [Features](#features)
* [Gotchas](#gotchas)
* [Quick start](#quick-start)
* [Finding help and documentation](#finding-help-and-documentation)
* [How to contribute](#how-to-contribute)
* [License](#license)

## Features

There are many ways to automate deployments, from simple rsync bash scripts to complex containerized toolchains. Capistrano sits somewhere in the middle: it automates what you already know how to do manually with SSH, but in a repeatable, scalable fashion. There is no magic here!

Here's what makes Capistrano great:

#### Strong conventions

Capistrano defines a standard deployment process that all Capistrano-enabled projects follow by default. You don't have to decide how to structure your scripts, where deployed files should be placed on the server, or how to perform common tasks: Capistrano has done this work for you.

#### Multiple stages

Define your deployment once, and then easily parameterize it for multiple *stages* (environments), e.g. `qa`, `staging`, and `production`. No copy-and-paste necessary: you only need to specify what is different for each stage, like IP addresses.

#### Parallel execution

Deploying to a fleet of app servers? Capistrano can run each deployment task concurrently across those servers and uses connection pooling for speed.

#### Server roles

Your application may need many different types of servers: a database server, an app server, two web servers, and a job queue work server, for example. Capistrano lets you tag each server with one or more roles, so you can control what tasks are executed where.

#### Community driven

Capistrano is easily extensible using the rubygems package manager. Deploying a Rails app? Wordpress? Laravel? Chances are, someone has already written Capistrano tasks for your framework of choice and has distributed it as a gem. Many Ruby projects also come with Capistrano tasks built-in.

#### It's just SSH

Everything in Capistrano comes down to running SSH commands on remote servers. On the one hand, that makes Capistrano simple. On the other hand, if you aren't comfortable SSH-ing into a Linux box and doing stuff on the command-line, then Capistrano is probably not for you.

## Gotchas

While Capistrano ships with a strong set of conventions that are common for all types of deployments, it needs help understanding the specifics of your project, and there are some things Capistrano is not suited to do.

#### Project specifics

Out of the box, Capistrano can deploy your code to server(s), but it does not know how to *execute* your code. Does `foreman` need to be run? Does Apache need to be restarted? You'll need to tell Capistrano how to do this part by writing these deployment steps yourself, or by finding a gem in the Capistrano community that does it for you.

#### Key-based SSH

Capistrano depends on connecting to your server(s) with SSH using key-based (i.e. password-less) authentication. You'll need this working before you can use Capistrano.

#### Provisioning

Likewise, your server(s) will likely need supporting software installed before you can perform a deployment. Capistrano itself has no requirements other than SSH, but your application probably needs database software, a web server like Apache or Nginx, and a language runtime like Java, Ruby, or PHP. These *server provisioning* steps are not done by Capistrano.

#### `sudo`, etc.

Capistrano is designed to deploy using a single, non-privileged SSH user, using a *non-interactive* SSH session. If your deployment requires `sudo`, interactive prompts, authenticating as one user but running commands as another, you can probably accomplish this with Capistrano, but it may be difficult. Your automated deployments will be much smoother if you can avoid such requirements.

#### Shells

Capistrano 3 expects a POSIX shell like Bash or Sh. Shells like tcsh, csh, and such may work, but probably will not.

## Quick start

### Requirements

* Ruby version 2.0 or higher on your local machine (MRI or Rubinius)
* A project that uses source control (Git, Mercurial, and Subversion support is built-in)
* The SCM binaries (e.g. `git`, `hg`) needed to check out your project must be installed on the server(s) you are deploying to
* [Bundler](http://bundler.io), along with a Gemfile for your project, are recommended

### Install the Capistrano gem

Add Capistrano to your project's Gemfile using `require: false`:

``` ruby
group :development do
  gem "capistrano", "~> 3.17", require: false
end
```

Then run Bundler to ensure Capistrano is downloaded and installed:

``` sh
$ bundle install
```

### "Capify" your project

Make sure your project doesn't already have a "Capfile" or "capfile" present. Then run:

``` sh
$ bundle exec cap install
```

This creates all the necessary configuration files and directory structure for a Capistrano-enabled project with two stages, `staging` and `production`:

```
├── Capfile
├── config
│   ├── deploy
│   │   ├── production.rb
│   │   └── staging.rb
│   └── deploy.rb
└── lib
    └── capistrano
            └── tasks
```

To customize the stages that are created, use:

``` sh
$ bundle exec cap install STAGES=local,sandbox,qa,production
```

Note that the files that Capistrano creates are simply templates to get you started. Make sure to edit the `deploy.rb` and stage files so that they contain values appropriate for your project and your target servers.

### Command-line usage

``` sh
# list all available tasks
$ bundle exec cap -T

# deploy to the staging environment
$ bundle exec cap staging deploy

# deploy to the production environment
$ bundle exec cap production deploy

# simulate deploying to the production environment
# does not actually do anything
$ bundle exec cap production deploy --dry-run

# list task dependencies
$ bundle exec cap production deploy --prereqs

# trace through task invocations
$ bundle exec cap production deploy --trace

# lists all config variable before deployment tasks
$ bundle exec cap production deploy --print-config-variables
```

## Finding help and documentation

Capistrano is a large project encompassing multiple GitHub repositories and a community of plugins, and it can be overwhelming when you are just getting started. Here are resources that can help:

* **The [docs](docs) directory contains the official documentation**, and is used to generate the [Capistrano website](http://capistranorb.com)
* [Stack Overflow](http://stackoverflow.com/questions/tagged/capistrano) has a Capistrano tag with lots of activity
* [The Capistrano mailing list](https://groups.google.com/forum/#!forum/capistrano) is low-traffic but is monitored by Capistrano contributors
* [CodersClan](http://codersclan.net/?repo_id=325&source=link) has Capistrano experts available to solve problems for bounties

Related GitHub repositories:

* [capistrano/sshkit](https://github.com/capistrano/sshkit) provides the SSH behavior that underlies Capistrano (when you use `execute` in a Capistrano task, you are using SSHKit)
* [capistrano/rails](https://github.com/capistrano/rails) is a very popular gem that adds Ruby on Rails deployment tasks
* [mattbrictson/airbrussh](https://github.com/mattbrictson/airbrussh) provides Capistrano's default log formatting

GitHub issues are for bug reports and feature requests. Please refer to the [CONTRIBUTING](CONTRIBUTING.md) document for guidelines on submitting GitHub issues.

If you think you may have discovered a security vulnerability in Capistrano, do not open a GitHub issue. Instead, please send a report to <security@capistranorb.com>.

## How to contribute

Contributions to Capistrano, in the form of code, documentation or idea, are gladly accepted. Read the [DEVELOPMENT](DEVELOPMENT.md) document to learn how to hack on Capistrano's code, run the tests, and contribute your first pull request.

## License

MIT License (MIT)

Copyright (c) 2012-2020 Tom Clements, Lee Hambley

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
