# Capistrano [![Build Status](https://travis-ci.org/capistrano/capistrano.png?branch=v3)](https://travis-ci.org/capistrano/capistrano) [![Code Climate](https://codeclimate.com/github/capistrano/capistrano.png)](https://codeclimate.com/github/capistrano/capistrano)

## Requirements

* Ruby >= 1.9 (JRuby and C-Ruby/YARV are supported)

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'capistrano', '~> 3.0.1'
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
    info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
  end
end
```

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
task :one do
  on roles(:all) { info "One" }
end
task :two do
  invoke :one
  on roles(:all) { info "Two" }
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


## Running local tasks

Local tasks can be run by replacing `on` with `run_locally`

``` ruby
desc "Notify service of deployment"
task :notify do
  run_locally do
    with rails_env: :development do
      rake 'service:notify'
    end
  end
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
*tell the backend that this is an **interactive** session*. This is normally a bad idea.

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
| `:repo_url`           | The URL of your Git repository                                       | file://, https://, or ssh:// are all supported                  |
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

## Licence

The MIT License (MIT)

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
