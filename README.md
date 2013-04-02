## Capistrano

[![Build
Status](https://secure.travis-ci.org/capistrano/capistrano.png)](http://travis-ci.org/capistrano/capistrano)[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/capistrano/capistrano)


Capistrano is a utility and framework for executing commands in parallel on
multiple remote machines, via SSH. It uses a simple DSL (borrowed in part from
[Rake](http://rake.rubyforge.org/)) that allows you to define _tasks_, which may
be applied to machines in certain roles. It also supports tunneling connections
via some gateway machine to allow operations to be performed behind VPN's and
firewalls.

Capistrano was originally designed to simplify and automate deployment of web
applications to distributed environments, and originally came bundled with a set
of tasks designed for deploying Rails applications.

## Documentation

* [https://github.com/capistrano/capistrano/wiki](https://github.com/capistrano/capistrano/wiki)

## DEPENDENCIES

* [Net::SSH](http://net-ssh.rubyforge.org)
* [Net::SFTP](http://net-ssh.rubyforge.org)
* [Net::SCP](http://net-ssh.rubyforge.org)
* [Net::SSH::Gateway](http://net-ssh.rubyforge.org)
* [HighLine](http://highline.rubyforge.org)
* [Ruby](http://www.ruby-lang.org/en/) &#x2265; 1.8.7

If you want to run the tests, you'll also need to install the dependencies with
Bundler, see the `Gemfile` within .

## ASSUMPTIONS

Capistrano is "opinionated software", which means it has very firm ideas about
how things ought to be done, and tries to force those ideas on you. Some of the
assumptions behind these opinions are:

* You are using SSH to access the remote servers.
* You either have the same password to all target machines, or you have public
  keys in place to allow passwordless access to them.

Do not expect these assumptions to change.

## USAGE

In general, you'll use Capistrano as follows:

* Create a recipe file ("capfile" or "Capfile").
* Use the `cap` script to execute your recipe.

Use the `cap` script as follows:

    cap sometask

By default, the script will look for a file called one of `capfile` or
`Capfile`. The `sometask` text indicates which task to execute. You can do
"cap -h" to see all the available options and "cap -T" to see all the available
tasks.

## CONTRIBUTING:

* Fork Capistrano
* Create a topic branch - `git checkout -b my_branch`
* Rebase your branch so that all your changes are reflected in one
  commit
* Push to your branch - `git push origin my_branch`
* Create a Pull Request from your branch, include as much documentation
  as you can in the commit message/pull request, following these
[guidelines on writing a good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
* That's it!


## LICENSE:

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
