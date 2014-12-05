# Capistrano [![Build Status](https://travis-ci.org/capistrano/capistrano.svg?branch=master)](https://travis-ci.org/capistrano/capistrano) [![Code Climate](http://img.shields.io/codeclimate/github/capistrano/capistrano.svg)](https://codeclimate.com/github/capistrano/capistrano) <a href="http://codersclan.net/?repo_id=325&source=small"><img src="http://img.shields.io/badge/get-support-blue.svg"></a>

## Requirements

* Ruby >= 1.9.3 (JRuby and C-Ruby/YARV are supported)

## Support

Need help with getting Capistrano up and running? Got a code problem you want to get solved quickly?

Get <a href="http://codersclan.net/?repo_id=325&source=link">Capistrano support on CodersClan.</a>

<a href="http://codersclan.net/?repo_id=325&source=big"><img src="http://www.codersclan.net/gs_button/?repo_id=325" width="200"></a>

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'capistrano', '~> 3.3.0'
```

And then execute:

``` sh
$ bundle install
```

Capify:
*make sure there's no "Capfile" or "capfile" present*
``` sh
$ bundle exec cap install
```

This creates the following files:

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

To create different stages:

``` sh
$ bundle exec cap install STAGES=local,sandbox,qa,production
```

## Usage

``` sh
$ bundle exec cap -T

$ bundle exec cap staging deploy
$ bundle exec cap production deploy

$ bundle exec cap production deploy --dry-run
$ bundle exec cap production deploy --prereqs
$ bundle exec cap production deploy --trace
```

## Tasks

``` ruby
server 'example.com', roles: [:web, :app]
server 'example.org', roles: [:db, :workers]
desc "Report Uptimes"
task :uptime do
  on roles(:all) do |host|
    execute :any_command, "with args", :here, "and here"
    info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
  end
end
```

**Note**:

**tl;dr**: `execute(:bundle, :install)` and `execute('bundle install')` don't behave identically!

`execute()` has a subtle behaviour. When calling `within './directory' { execute(:bundle, :install) }` for example, the first argument to `execute()` is a *Stringish* with ***no whitespace***. This allows the command to pass through the [SSHKit::CommandMap](https://github.com/capistrano/sshkit#the-command-map) which enables a number of powerful features.

When the first argument to `execute()` contains whitespace, for example `within './directory' { execute('bundle install') }` (or when using a heredoc), neither Capistrano, nor SSHKit can reliably predict how it should be shell escaped, and thus cannot perform any context, or command mapping, that means that the `within(){}` (as well as `with()`, `as()`, etc) have no effect. There have been a few attempts to resolve this, but we don't consider it a bug although we acknowledge that it might be a little counter intuitive.
## Before / After

Where calling on the same task name, executed in order of inclusion

``` ruby
# call an existing task
before :starting, :ensure_user

after :finishing, :notify


# or define in block
before :starting, :ensure_user do
  #
end

after :finishing, :notify do
  #
end
```

If it makes sense for your use case (often, that means *generating a file*)
the Rake prerequisite mechanism can be used:

``` ruby
desc "Create Important File"
file 'important.txt' do |t|
  sh "touch #{t.name}"
end
desc "Upload Important File"
task :upload => 'important.txt' do |t|
  on roles(:all) do
    upload!(t.prerequisites.first, '/tmp')
  end
end
```

The final way to call out to other tasks is to simply `invoke()` them:

``` ruby
namespace :example do
  task :one do
    on roles(:all) { info "One" }
  end
  task :two do
    invoke "example:one"
    on roles(:all) { info "Two" }
  end
end
```

This method is widely used.

## Getting User Input

``` ruby
desc "Ask about breakfast"
task :breakfast do
  ask(:breakfast, "pancakes")
  on roles(:all) do |h|
    execute "echo \"$(whoami) wants #{fetch(:breakfast)} for breakfast!\""
  end
end
```

Perfect, who needs telephones.

When using `ask` to get user input, you can pass `echo: false` to prevent the input from being displayed:

```ruby
ask(:database_password, "default", echo: false)
```

## Using password authentication

Password authentication can be done via `set` and `ask` in your deploy environment file (e.g.: config/deploy/production.rb)

```ruby
set :password, ask('Server password', nil)
server 'server.domain.com', user: 'ssh_user_name', port: 22, password: fetch(:password), roles: %w{web app db}
```

## Running local tasks

Local tasks can be run by replacing `on` with `run_locally`

``` ruby
desc 'Notify service of deployment'
task :notify do
  run_locally do
    with rails_env: :development do
      rake 'service:notify'
    end
  end
end
```

Of course, you can always just use standard ruby syntax to run things locally
``` ruby
desc 'Notify service of deployment'
task :notify do
  %x('RAILS_ENV=development bundle exec rake "service:notify"')
end
```

Alternatively you could use the rake syntax
``` ruby
desc "Notify service of deployment"
task :notify do
   sh 'RAILS_ENV=development bundle exec rake "service:notify"'
end
```
## Console

**Note:** Here be dragons. The console is very immature, but it's much more
cleanly architected than previous incarnations and it'll only get better from
here on in.

Execute arbitrary remote commands, to use this simply add
`require 'capistrano/console'` which will add the necessary tasks to your
environment:

``` sh
$ bundle exec cap staging console
```

Then, after setting up the server connections, this is how that might look:

``` sh
$ bundle exec cap production console
capistrano console - enter command to execute on production
production> uptime
 INFO [94db8027] Running /usr/bin/env uptime on leehambley@example.com:22
DEBUG [94db8027] Command: /usr/bin/env uptime
DEBUG [94db8027]   17:11:17 up 50 days, 22:31,  1 user,  load average: 0.02, 0.02, 0.05
 INFO [94db8027] Finished in 0.435 seconds command successful.
production> who
 INFO [9ce34809] Running /usr/bin/env who on leehambley@example.com:22
DEBUG [9ce34809] Command: /usr/bin/env who
DEBUG [9ce34809]  leehambley pts/0        2013-06-13 17:11 (port-11262.pppoe.wtnet.de)
 INFO [9ce34809] Finished in 0.420 seconds command successful.
```

## VCS Requirements

Capistano requires modern versions of Git, Mercurial and Subversion
respectively (if you are using that particular VCS). Git requirement is at
least version 1.8.x. Mercurial and Subversion, any modern version should
suffice.

## A word about PTYs

There is a configuration option which asks the backend driver to ask the remote host
to assign the connection a *pty*. A *pty* is a pseudo-terminal, which in effect means
*tell the backend that this is an __interactive__ session*. This is normally a bad idea.

Most of the differences are best explained by [this page](https://github.com/sstephenson/rbenv/wiki/Unix-shell-initialization) from the author of *rbenv*.

**When Capistrano makes a connection it is a *non-login*, *non-interactive* shell.
This was not an accident!**

It's often used as a band aid to cure issues related to RVM and rbenv not loading login
and shell initialisation scripts. In these scenarios RVM and rbenv are the tools at fault,
or at least they are being used incorrectly.

Whilst, especially in the case of language runtimes (Ruby, Node, Python and friends in
particular) there is a temptation to run multiple versions in parallel on a single server
and to switch between them using environmental variables, this is an anti-pattern, and
symptomatic of bad design (e.g. you're testing a second version of Ruby in production because
your company lacks the infrastructure to test this in a staging environment).

## Configuration

The following variables are settable:

| Variable Name         | Description                                                          | Notes                                                           |
|:---------------------:|----------------------------------------------------------------------|-----------------------------------------------------------------|
| `:repo_url`           | The URL of your scm repository (git, hg, svn)                        | file://, https://, ssh://, or svn+ssh:// are all supported      |
| `:repo_tree`          | The subtree of the scm repository to deploy (git, hg)                | Only implemented for git and hg repos. Extract just this tree   |
| `:branch`             | The branch you wish to deploy                                        | This only has meaning for git and hg repos, to specify the branch of an svn repo, set `:repo_url` to the branch location. |
| `:scm`                | The source control system used                                       | `:git`, `:hg`, `:svn` are currently supported                   |
| `:tmp_dir`            | The (optional) temp directory that will be used (default: /tmp)      | if you have a shared web host, this setting may need to be set (i.e. /home/user/tmp/capistrano). |

__Support removed__ for following variables:

| Variable Name         | Description                                                         | Notes                                                           |
|:---------------------:|---------------------------------------------------------------------|-----------------------------------------------------------------|
| `:copy_exclude`       | The (optional) array of files and/or folders excluded from deploy | Replaced by Git's native `.gitattributes`, see [#515](https://github.com/capistrano/capistrano/issues/515) for more info. |

## Host and Role Filtering

Capistrano enables the declaration of servers and roles, each of which may have properties
associated with them.  Tasks are then able to use these definitions in two distinct ways:

* To determine _configurations_: typically by using the `roles()`, `release_roles()` and
  `primary()` methods. Typically these are used outside the scope of the `on()` method.

* To _interact_ with remote hosts using the `on()` method

An example of the two would be to create a `/etc/krb5.conf` file containing the list of
available KDC's by using the list of servers returned by `roles(:kdc)` and then uploading
it to all client machines using `on(roles(:all)) do upload!(file) end`

A problem with this arises when _filters_ are used. Filters are designed to limit the
actual set of hosts that are used to a subset of those in the overall stage, but how
should that apply in the above case?

If the filter applies to both the _interaction_ and _configuration_ aspects, any configuration
files deployed will not be the same as those on the hosts excluded by the filters. This is
almost certainly not what is wanted, the filters should apply only to the _interactions_
ensuring that any configuration files deployed will be identical across the stage.

Another type of filtering is done by defining properties on servers and selecting on that
basis. An example of that is the 'no_release' property and it's use in the
`release_roles()` method. To distinguish these two types of filtering we name them:

* On-Filtering
    Specified in the following ways:
    * Via environment variables HOSTS and ROLES
    * Via command line options `--hosts` and `--roles`
    * Via the `:filter` variable set in a stage file
* Property-Filtering
    These are specified by options passed to the `roles()` method (and implicitly in methods
    like `release_roles()` and `primary()`)

To increase the utility of On-Filters they can use regular expressions:
* If the host name in a filter doesn't match `/^[-A-Za-z0-9.]+$/` (the set of valid characters
    for a DNS name) then it's assumed to be a regular expression.
* Since role names are Ruby symbols they can legitimately contain any characters. To allow multiple
    of them to be specified on one line we use the comma. To use a regexp for a role filter begin
    and end the string with '/'. These may not contain a comma.

When filters are specified using comma separated lists, the final filter is the _union_ of
all of the components. However when multiple filters are declared the result is the
_intersection_.

## SSHKit

[SSHKit](https://github.com/leehambley/sshkit) is the driver for SSH
connections behind the scenes in Capistrano. Depending on how deep you dig, you
might run into interfaces that come directly from SSHKit (the configuration is
a good example).

## Testing

Capistrano has two test suites: an RSpec suite and a Cucumber suite. The
RSpec suite handles quick feedback unit specs. The Cucumber features are
an integration suite that uses Vagrant to deploy to a real virtual
server. In order to run the Cucumber suite you will need to install
[Vagrant](http://www.vagrantup.com/) and Vagrant supported
virtualization software like
[VirtualBox](https://www.virtualbox.org/wiki/Downloads).

```
# To run the RSpec suite
$ rake spec

# To run the Cucumber suite
$ rake features

# To run the Cucumber suite and leave the VM running (faster for subsequent runs)
$ rake features KEEP_RUNNING=1
```

## Metrics

Since version 3.3.3 Capistrano includes anonymous metrics. The metric server,
gem collection, and when it exists, the HTML/d3 page to view the metrics are
all open-source and available for inspection and audit at
https://github.com/capistrano/stats

**Notes for CI**: If you commit the file `.capistrano/metrics` to your source
control, you will not be prompted again, this is what we expect you to do, and
it should also avoid breaking your CI server by blocking waiting for an answer
on standard in. The metric prompt is also [disabled when standard in is not a
tty](https://github.com/capistrano/stats/blob/77c9993d3ee604520712261aa2a70c90f3b96a6f/gem/lib/capistrano-stats/metric-collector.rb#L53)
(when using Capistrano from scripts, or from come well behaved CI services)

* The gem invites users to opt-into metrics collection when the task
  `load:defaults` is called. A project-specific hash derived from the output of
  `git config remote.origin.url` is written to a file `.capistrano/metrics` to
  allow us to differentiate between many members of the same team deploying the
  same project vs. many people on many projects.

## License

MIT License (MIT)

Copyright (c) 2012-2015 Tom Clements, Lee Hambley

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
