# Capistrano [![Build Status](https://travis-ci.org/capistrano/capistrano.png?branch=v3)](https://travis-ci.org/capistrano/capistrano) [![Code Climate](https://codeclimate.com/github/capistrano/capistrano.png)](https://codeclimate.com/github/capistrano/capistrano) <a href="http://codersclan.net/?repo_id=325&source=small"><img src="http://www.codersclan.net/gs_button/?repo_id=325&size=small" width="69"></a>

## Requirements

* Ruby >= 1.9 (JRuby and C-Ruby/YARV are supported)

## Support

Need help with getting Capistrano up and running? Got a code problem you want to get solved quickly?

Get <a href="http://codersclan.net/?repo_id=325&source=link">Capistrano support on CodersClan.</a>

<a href="http://codersclan.net/?repo_id=325&source=big"><img src="http://www.codersclan.net/gs_button/?repo_id=325" width="200"></a>

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'capistrano', '~> 3.2.0'
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
$ bundle exec cap -vT

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
| `:branch`             | The branch you wish to deploy                                        | This only has meaning for git and hg repos, to specify the branch of an svn repo, set `:repo_url` to the branch location. |
| `:scm`                | The source control system used                                       | `:git`, `:hg`, `:svn` are currently supported                   |
| `:tmp_dir`            | The (optional) temp directory that will be used (default: /tmp)      | if you have a shared web host, this setting may need to be set (i.e. /home/user/tmp/capistrano). |

__Support removed__ for following variables:

| Variable Name         | Description                                                         | Notes                                                           |
|:---------------------:|---------------------------------------------------------------------|-----------------------------------------------------------------|
| `:copy_exclude`       | The (optional) array of files and/or folders excluded from deploy | Replaced by Git's native `.gitattributes`, see [#515](https://github.com/capistrano/capistrano/issues/515) for more info. |

## SSHKit

[SSHKit](https://github.com/leehambley/sshkit) is the driver for SSH
connections behind the scenes in Capistrano. Depending on how deep you dig, you
might run into interfaces that come directly from SSHKit (the configuration is
a good example).

## License

MIT License (MIT)

Copyright (c) 2012-2013 Tom Clements, Lee Hambley

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
