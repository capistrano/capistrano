# Capistrano [![Build Status](https://travis-ci.org/capistrano/capistrano.png?branch=v3)](https://travis-ci.org/capistrano/capistrano)

## Requirements

* Ruby >= 1.9 (JRuby and C-Ruby/MRI are supported)

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'capistrano', github: 'capistrano/capistrano', branch: :v3
```

And then execute:

``` ruby
$ bundle --binstubs
```

Capify:

``` shell
$ cap install
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

``` shell
$ cap install STAGES=local,sandbox,qa,production
```

## Usage

``` shell
$ cap -vT

$ cap staging deploy
$ cap production deploy

$ cap production deploy --dry-run
$ cap production deploy --prereqs
$ cap production deploy --trace
```

## Tasks

``` ruby
server 'example.com', roles: [:web, :app]
server 'example.org', roles: [:db, :workers]
desc "Report Uptimes"
task :uptime do
  on roles(:all) do |host|
    info "Host #{host} (#{host.roles.join(', ')}):\t#{capture(:uptime)}"
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

If it makes sense for your use-case (often, that means *generating a file*)
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
  breakfast = ask(:breakfast, "What would you like your colleagues to you for breakfast?")
  on roles(:all) do |h|
    execute "echo \"$(whoami) wants #{breakfast} for breakfast!\" | wall"
  end
end
```

Perfect, who needs telephones.

## Console

**Note:** Here be dragons. The console is very immature, but it's much more
cleanly architected than previous incarnations and it'll only get better from
here on in.

Execute arbitrary remote commands, to use this simply add
`require 'capistrano/console'` which will add the necessary tasks to your
environment:

``` shell
$ cap staging console
```

Then, after setting up the server connections, this is how that might look:

```
$ cap production console
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

There is a configuration option which asks the backend driver to as the remote host
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
sympotamtic of bad design (i.e. you're testing a second version of Ruby in production because
your company lacks the infrastructure to test this in a staging environment)

## Configuration


## SSHKit

[SSHKit][https://github.com/capistrano/sshkit] is the driver for SSH
connections behind the scenes in Capistrano, depending how deep you dig, you
might run into interfaces that come directly from SSHKit (the configuration is
a good example).
