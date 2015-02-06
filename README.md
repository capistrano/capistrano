# Capistrano [![Build Status](https://travis-ci.org/capistrano/capistrano.svg?branch=master)](https://travis-ci.org/capistrano/capistrano) [![Code Climate](http://img.shields.io/codeclimate/github/capistrano/capistrano.svg)](https://codeclimate.com/github/capistrano/capistrano) <a href="http://codersclan.net/?repo_id=325&source=small"><img src="http://img.shields.io/badge/get-support-blue.svg"></a>

## Documentation

Check out the [online documentation](http://capistranorb.com) of Capistrano 3 hosted via this [repository](https://github.com/capistrano/capistrano.github.io).

## Support

Need help with getting Capistrano up and running? Got a code problem you want to get solved quickly?

Get <a href="http://codersclan.net/?repo_id=325&source=link">Capistrano support on CodersClan.</a> <a href="http://codersclan.net/?repo_id=325&source=big"><img src="http://www.codersclan.net/gs_button/?repo_id=325" width="150"></a>

## Requirements

* Ruby >= 1.9.3 (JRuby and C-Ruby/YARV are supported)

Capistrano support these source code version control systems out of the box:

* Git 1.8 or higher
* Mercurial
* SVN

Binaries for these VCS might be required on the local and/or the remote systems.

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
```

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

## SSHKit

[SSHKit](https://github.com/leehambley/sshkit) is the driver for SSH
connections behind the scenes in Capistrano. Depending on how deep you dig, you
might run into interfaces that come directly from SSHKit (the configuration is
a good example).

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
