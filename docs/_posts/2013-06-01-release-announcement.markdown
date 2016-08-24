---
layout: post
title: "Capistrano Version 3 Release Announcement"
date:   2013-06-01
---

After what seems like years of work, the Capistrano team (that's Tom and I)
are pleased to announce the first *major* release of Capistrano in almost 5
years.

The reasons behind the length of time between the last architectural overhaul
and this one are numerous, but it can be summarised to say that Capistrano is a
widely used tool, and when working around software deployment it's really a
question of downtime. If we had changed something significant in Capistrano we
could have taken a lot of sites offline, and made a lot of people very
unhappy. Until this point we haven't felt that the time has been ripe where
the benefits of a slightly rocky upgrade path are worth the risks of downtime.

It also hasn't helped historically that we've only just gotten to grips with
Ruby 1.9, and that Bundler's near ubiquity means that now it's trivial to lock
a Gem at a specific version. With other tools in the Ruby ecosystem it's
become easier for us to make significant changes to a tool upon which many
hundreds of thousands of people rely.

### Design Goals

We had a few goals for this release, in no particular order they were:

* **Get away from our own DSL solution.** Great DSL alternatives (Rake, Sake, Thor,
  etc) are already widely used.
* **Better modularisation.** to enable people outside the Rails community to
  benefit from Capistrano's *best-practice* workflow, and to enable people in
  the Rails community to pick and choose support for components they use
  (Database Migrations, Asset Pipeline, etc)
* **Easier Debugging.** A lot of problems with Capistrano come from weirdness
  surrounding environmental issues around PTY vs non-TTY environments, login
  and non-login shells not to mention *environment managers* such as rvm,
  rbenv and nvm.
* **Speed.** We know that in a lot of environments speed of deployment is a
  huge factor, since Rails introduced the *Asset Pipeline* it's not uncommon
  for a deploy that formerly took 5 seconds now takes 5 minutes. This really
  is mostly out of our control, but with improved support for parallelism,
  rolling restarts we feel confident that things will be quicker and easier to
  keep running quickly now.
* **Applicability.** We've always maintained that Capistrano is a terrible
  tool for system provisioning, and that more often than not servers are
  better being setup with Chef, Puppet or similar, whilst we still agree with
  that, the new features in Capistrano really lend themselves to integrating
  with these kinds of tools.

### What's missing?

Before we get too carried away it's worth shortlisting the things that don't
exist in version three, ***yet***.

* **SSH Gateway Support** SSH Gateway support hasn't been implemented in
  version three yet, I hope that this will be done soon. As I have no direct
  need for it, I haven't the means to test it with a view to implementing it,
  yet.
* **Mecurial, Subversion, and CVS Support** These have been removed as we've
  been able to implement the Git SCM in an incredibly neat way that isn't
  compatible with the others. We wanted to break the cycle of always sticking
  with the lowest common denominator, so we are **actively** looking for
  people who are interested in contributing, or sharing expertise on the
  *best-practice* way of speedily deploying from your respective choice of
  source control.
* **`HOSTFILTER` ,`ROLEFILTER` and friends** These have gone away because we
  always felt they were endemic of a bad design decision about using
  Environmental Variables. These will be coming back as flags passed to `cap`
  on the CLI, and options that can be set on the `Capistrano::Application` Ruby
  class.
* **Shell** The shell has been removed temporarily pending a neater
  implementation, we've got something that we are playing with internally, but
  it needs better `readline` support, and some more controls around what to do
  when things go badly on some servers, but not others.
* **Cold Deploy** The `cap deploy:cold` is a really old legacy component,
  orignally from the days of the `script/spinner` where deploying cold
  (starting workers that weren't running), and deploying a *warm* system were
  different (restarting existing worker pools, which wasn't fun!) By and large
  these things have gone away, and it's time `deploy:cold` went away. It's
  safe in every case we could find to call setup, and seed and other Rake
  tasks without things blowing up, and that should be the approach we take.
  Tasks on the server should be idempotent, and if something is called twice,
  let it be.

### What's new?

Each section here really deserves it's own sub-heading as some of the new
features are awesome.

#### Rake Integration

We have moved away from our own DSL implemenation to implement Capistrano as a
*Rake* application.

Rake has always supported being sub-classed, so to speak as a
*sub-application*; it is however poorly documented. By subclassing
`Rake::Application` one can specify what the *Rakefile* should look like, where
to search for it, and how to load other *Rakefiles*.

The *Rake* DSL is widely used, well known and very powerful. As Rake is
essentially a dependency resolution system, it offers a lot of nice ways to,
for example build a tarball as a dependency of uploading it and deploying it.

This has allowed us to do away with the *copy* strategy all together, as it
can now be implemented from scratch in fewer than ten lines of code.

The guiding principle is dependency resolution, and interoperability with
other tools, for example:

{% highlight ruby %}
    # Capistrano 3.0.x
    task :notify do
      this_release_tag = sh("git describe --abbrev=0 --tags")
      last_ten_commits = sh("git log #{this_release_tag}~10..#{this_release_tag}")
      Mail.deliver do
        to      "team@example.com"
        subject "Releasing #{this_release_tag} Now!"
        body    last_ten_commits
      end
    end

    namespace :deploy
      task default: :notify
    end
{% endhighlight %}

The last three lines rely on Rake's additive task declaration, by redefining the
`deploy:default` task by adding another dependency. Rake will automatically
resolve this dependency at Runtime, mailing the recent changelog to your team,
assuming everything is setup correctly.

#### Built-In Stage Support

In former versions of Capistrano *stage* support was an after thought,
provided through the `capistrano-ext` Gem, and laterally merged into the main
codebase, people insisted in still using the `capistrano-ext` version
regardless.

In Capistrano 3.0.x there's stage support built-in, at installation time, two
stages will be created by default, *staging* and *production*; it's easy to
add more, just add a file to `config/deploy/______.rb` which follows the
conventions established in the examples we created for you.

To create different stages at installation time, simply set the `STAGES`
environmental variable to a comma separated list of stages:

{% highlight bash %}
    $ cap install STAGES=staging,production,ci,qa
{% endhighlight %}

#### Parallelism

In former versions of Capistrano there was a *parallel* option to run
different tasks differently on groups of servers, it looked something like
this:

{% highlight ruby %}
    # Capistrano 2.0.x
    task :restart do
      parallel do |session|
        session.when "in?(:app)", "/u/apps/social/script/restart-mongrel"
        session.when "in?(:web)", "/u/apps/social/script/restart-apache"
        session.else "echo nothing to do"
      end
    end
{% endhighlight %}

This always felt a little unclean, and indeed it's a hack that was originally
implemeted to facilitate rolling deployments at a large German firm by a
couple of freelancers who were consulting with them. (Hint, one of those guys
went on to found Travis-CI!)

The equivalent code in under Capistrano v3 would look like this:

{% highlight ruby %}
    # Capistrano 3.0.x
    task :restart do
      on :all, in: :parallel do |host|
        if host.roles.include?(:app)
          execute "/u/apps/social/script/restart-mongrel"
        elsif host.roles.include?(:web)
          execute "/u/apps/social/script/restart-web"
        else
          info sprintf("Nothing to do for %s with roles %s", host,
          host.properties.roles)
        end
      end
    end
{% endhighlight %}

The second block of code, that representing the new Rake derived DSL and
demonstrating how to use the parallel execution mode is a little longer, but I
think it's clearer, more idiomatic Ruby code which relies less on an intimate
knowledge of how the Capistrano DSL happens to work. It also hints at the
built-in logging subsystem, keep reading to learn more.

Other modes for parallelism include:

{% highlight ruby %}
    # Capistrano 3.0.x
    on :all, in: :groups, limit: 3, wait: 5 do
      # Take all servers, in groups of three which execute in parallel
      # wait five seconds between groups of servers.
      # This is perfect for rolling restarts
    end

    on :all, in: :sequence, wait: 15 do
      # This takes all servers, in sequence and waits 15 seconds between
      # each server, this might be perfect if you are afraid about
      # overloading a shared resource, or want to defer the asset compilation
      # over your cluster owing to worries about load
    end

    on :all, in: :parallel do
      # This will simply try and execute the commands contained within
      # the block in parallel on all servers. This might be perfect for kicking
      # off something like a Git checkout or similar.
    end
{% endhighlight %}

The internal tasks, for standard deploy recipes make use of all of these as is
appropriate for the normal case, no need to be afraid of scary slow deploys
again!

#### Streaming IO

This IO streaming model means that results from commands, the commands
themselves and any other arbitrary output are sent as objects to a class with
an `IO`ish interface, the class knows what to do with these things.  There's a
*progress* formatter which prints dots for each command that is called, as
well as a *pretty* formatter which prints the full command, it's output on
standard out and standard error, as well as the final return status. It would
be trivial to implement HTML formatters, or formatters that reported to your
IRC room, or to email. I look forward to seeing more of these cropping up in
the community.

#### Host Definition Access

If you didn't skim over the *Parallism* section above, you might have noticed we
did something clever that wasn't possible in Capistrano v2; we accessed the
`host` inside the execution block.

For a lot of reasons in Capistrano v2 is wasn't possible to do this, the block
was essentially evaluated once and called verbatim on each host. This lead to
disappointing missing features such as not being able to pull the host list
out of Capistrano and examine the roles to do something like controlling Chef
solo, or similar.

In Capistrano v3 the `host` object is the same object that is created when a
server is defined, and is internally used, for example to pass to an ERB
template for rendering a last-deploy message that is dumped onto each server
after a successful deployment. The last deploy log includes everything
Capistrano knew about that server during the deployment.

> Users of Capistrano v2 may be familiar with the perenial `cap deploy:cleanup`
problem which came to light when servers differed in their old releases list,
imagine a scenario with two servers, one has been your bread-and-butter since
you launched, it has hundreds of old releases from all your wonderful deploys
over the months or years. The second server has been in the cluster for about
a month, it didn't quite slot-in cleanly, so the list of old releases looks a
bit weird, you deleted a few by hand, and anyway there might only be ten-or-so
releases there.

> Now imagine that you call `cap deploy:cleanup`, old `capture()`
implementations silently only ran on the first server that matched the
properties defined, so server one returned a list of ~95 old timestamped
release directories. Next Capistrano v2 would call `rm -rf
release1..release95` on **both** servers, causing server two to error out, and
leaving an undefined state on server one, as Capistrano would simply hang up
both connections.

This cleanup routine can now be better implemented as follows (which is
actually more or less the actual implementation in the the new Gem):

{% highlight ruby %}
    # Capistrano 3.0.x
    desc "Cleanup all old releases (keeps #{fetch(:releases_to_keep_on_cleanup)}
    old releases"
    task :cleanup do
      keep_releases     = fetch(:releases_to_keep_on_cleanup)
      releases          = capture(:ls, fetch(:releases_directory))
      releases_to_delete = releases.sort_by { |r| r.to_i }.slice(1..-(keep_releases + 1))
      releases_to_delete.each do |r|
        execute :rm, fetch(:releases_directory).join(r)
      end
    end
{% endhighlight %}

Some handy things to note here are that both server one and server two in our
contrived example will both evaluate that independently, and when both servers
are finished removing old releases the `task :cleanup` block will have
finished.

Also in Capistrano v3 most path variables are [`Pathname`] objects, so they natively
respond to things like `#basename`, `#expand_path`, `#join` and similar.

**Warning:** `#expand_path` probably won't do what you expect, it will execute
on your *workstation* machine, and not on the remote host, so it's possible
that it will return an error in the case of paths which exist remotely but not
locally.

#### Host Properties

As the `host` object is now available to the task blocks, it made sense to make
it possible to store arbitrarty values against them.

Enter `host.properties`. This is a simple
[*OpenStruct*](http://www.ruby-doc.org/stdlib-2.0/libdoc/ostruct/rdoc/OpenStruct.html)
which can be used to store any additional properties which are important for
your application.

An example of it's usage might be:

{% highlight ruby %}
    h = SSHKit::Host.new 'example.com'
    h.properties.roles ||= %i{wep app}
{% endhighlight %}

#### More Expressive Command Language

In Capistrano v2, it wasn't uncommon to find commands such as:

{% highlight ruby %}
    # Capistrano 2.0.x
    task :precompile, :roles => lambda { assets_role }, :except => { :no_release => true } do
      run <<-CMD.compact
        cd -- #{latest_release} &&
        RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} #{rake} assets:precompile
      CMD
    end
{% endhighlight %}

In Capistrano v3 this looks more like this:

{% highlight ruby %}
    # Capistrano 3.0.x
    task :precompile do
      on :sprockets_asset_host, reject: lambda { |h| h.properties.no_release } do
        within fetch(:latest_release_directory) do
          with rails_env: fetch(:rails_env) do
            execute :rake, 'assets:precompile'
          end
        end
      end
    end
{% endhighlight %}

Again, with other examples this format is a little longer, but much more
expressive, and all the nightmare of shell escaping is handled interally for
you, environmental variables are capitalised and applied at the correct point
(i.e between the `cd` and `rake` calls in this case).

Other options here include `as :a_user` and

#### Better *magic* Variable Support

In Capistrano v2 there were certain bits of magic where if calling a variable
and `NoMethodError` would have been raised (for example the
`latest_release_directory` variable). This variable never existed on the
global namespace, as a fall-back the list of `set()` variables would be
consulted.

This magic led to times when people were not recognising that magic variables
were even being used. The magic variable system of Capistrano v2 did also
include a way to `fetch(:some_variable, 'with a default value')` incase the
variable might not be set already, but it wasn't widely used, and more often
than not people just used things like `latest_release_directory` never knowing
that behind the scenes an exception was raised, then rescued, and that
`:latest_release_directory` in the variable map was actually a continuation
that was evaluated the first time it was used, and the value then cached until
the end of the script.

The system has now 100% less magic. If you set a variable using `set()`, it
can be fetched with `fetch()`, if the value you set into the variable responds
to `#call` then it will be executed in the current context whenever it is
used, the values will not be cached, unless your continuation does some
explicit caching. *Again, we are favoring clarity over micro optimisation*.

#### SSHKit

Many of the new features in Capistrano which relate to logging, formatting,
SSH, connection management and pooling, parallelism, batch execution and more
are from a library that fell out of the Capistrano v3 development process.

[*SSHKit*](https://github.com/leehambley/sshkit) is a lower level toolkit, a level higher than *Net::SSH* still,
but lacking the roles, environments, rollbacks and other higher level features
from Capistrano.

SSHkit is ideal for use if you need to just connect to a machine and run some
arbitrary command, for example:

{% highlight ruby %}
    # Rakefile (even without Capistrano loaded)
    require 'sshkit'
    desc "Check the uptime of example.com"
    task :uptime do |h|
      execute :uptime
    end
{% endhighlight %}

There is much more than can be done with SSHKit, and we have quite an
extensive [list of
examples](https://github.com/leehambley/sshkit/blob/master/EXAMPLES.md). For
the most part with Capistrano v3, anything that happens inside of an `on()`
block is happening in SSHkit, and the documentation from that library is the
place to go to find more information.

#### Command Mapping

This is another feature from SSHKit, designed to remove a little ambiguity
from preceedings, there is a so-called command map for commands.

When executing something like:

{% highlight ruby %}
    # Capistrano 2.0.x
    execute "git clone ........ ......."
{% endhighlight %}

The command is passed through to the remote server *completely unchanged*.
This includes the options which might be set, such as user, directory, and
environmental variables. **This is by design.** This feature is designed to
allow people to write non-trivial commands in
[heredocs](https://en.wikipedia.org/wiki/Here_document) when the need arises,
for example:

{% highlight ruby %}
    # Capistrano 3.0.x
    execute <<-EOBLOCK
      # All of this block is interpreted as Bash script
      if ! [ -e /tmp/somefile ]
        then touch /tmp/somefile
        chmod 0644 /tmp/somefile
      fi
    EOBLOCK
{% endhighlight %}

**Caveat:** The SSHKit multiline command sanitizing logic will remove line feeds and add an `;` after each line to separate the commands. So make sure you are not putting a newline between `then` and the following command.

The idiomatic way to write that command in Capistrano v3 is to use the
separated variadaric method to specify the command:

{% highlight ruby %}
    # Capistrano 3.0.x
    execute :git, :clone, "........", "......."
{% endhighlight %}

... or for the larger example

{% highlight ruby %}
    # Capistrano 3.0.x
    file = '/tmp/somefile'
    unless test("-e #{file}")
      execute :touch, file
    end
{% endhighlight %}

In this way the *command map* is consulted, the command map maps all unknown
commands (which in this case is `git`, the rest of the line are *arguments* to
`git` ) are mapped to `/usr/bin/env ...`. Meaning that this command would be
expanded to `/usr/bin/env git clone ...... ......` which is what happens when
`git` is called without a full path, the `env` program is consulted (perhaps
indirectly) to determine which `git` to run.

Commands such as `rake` and `rails` are often better prefixed by `bundle
exec`, and in this case could be mapped to:

{% highlight ruby %}
    SSHKit.config.command_map[:rake]  = "bundle exec rake"
    SSHKit.config.command_map[:rails] = "bundle exec rails"
{% endhighlight %}

There can also be a `lambda` or `Proc` applied in place of the mapping like so:

{% highlight ruby %}
    SSHKit.config.command_map = Hash.new do |hash, key|
      if %i{rails rake bundle clockwork heroku}.include?(key.to_sym)
        hash[key] = "/usr/bin/env bundle exec #{key}"
      else
        hash[key] = "/usr/bin/env #{key}"
      end
    end
{% endhighlight %}

Between these two options there should be quite powerful options to map
commands in your environment without having to override internal tasks from
Capistrano just because a path is different, or a binary has a different name.

This can also be *slightly* abused in environments where *shim* executables
are used, for example `rbenv` *wrappers*:

{% highlight ruby %}
    SSHKit.config.command_map = Hash.new do |hash, key|
      if %i{rails rake bundle clockwork heroku}.include?(key.to_sym)
        hash[key] = "/usr/bin/env myproject_bundle exec myproject_#{key}"
      else
        hash[key] = "/usr/bin/env #{key}"
      end
    end
{% endhighlight %}

The above assumes that you have done something like `rbenv wrapper default
myproject` which creates wrapper binaries which correctly set up the Ruby
environment without requiring an interactive login shell.

#### Testing

The old test suite for Capistrano was purely unit tests, and didn't cover a
wide variety of problem cases, specifically nothing in the `deploy.rb` (that is
the actual *deployment* code) was tested at all; because of having our own DSL
implementation, and other slightly odd design points, it was painful to test
the actual *recipes*.

Testing has been a focus of Capistrano v3. The *integration* test suite uses
Vagrant to boot a machine, configures certain scenarios using portable shell
script, and then executes commands against them, deploying common
configurations to typical Linux systems. This is slow to execute, but offers
stronger guarantees that nothing is broken that we've ever been able to give
before.

Capistrano v3 also offers a possibility to swap out backend implementations.
This is interesting because for the purpose of testing your *own* recipes you
can use a *printer* backend, and verify that the output matched what you
expected, or use a stubbed backend upon which you can verify that calls were
made, or not made as expected.

#### Arbitrary Logging

Capistrano exposes the methods `debug()`, `info()`, `warn()`, `error()` and
`fatal()` inside of `on()` blocks which can be used to log using the existing
logging infrastructure and streaming IO formatters:

{% highlight ruby %}
    # Capistrano 3.0.x
    on hosts do |host|
      f = '/some/file'
      if test("[ -d #{f} ]")
        execute :touch, f
      else
        info "#{f} already exists on #{host}!"
      end
    end
{% endhighlight %}

### Upgrading

The best place to go here is the [upgrading documentation](/documentation/upgrading/) to get deeper
into the specifics.

The simple version is to say that there is *no **direct** upgrade path*,
versions two and three are incompatible.

This is partly by design, the old DSL was imprecise in places that would have
made doing the right thing in most cases tricky, we opted to invest in more
features and better reliability than investing in keeping a backwards
compatible API.

There are a number of *gotchas* listed below, but the main points are the new
names of the built-in roles, as well as that by default Capistrano v3 is
platform agnostic, if you need Rails support, for migrations, asset pipeline
and such like, then it's required to `require` the support files.

### Gotchas

#### Rake DSL Is Additive

In Capistrano v2 if you re-define a task then it replaces the original
implemetation, this has been used by people to replace internal tasks
piecemeal with their own implementations

#### `sudo` Behaviour
