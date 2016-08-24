---
title: What is Capistrano?
layout: default
---

### Capistrano is a remote server automation tool.

It supports the scripting and execution of arbitrary tasks, and includes a set of sane-default deployment workflows.

Capistrano can be used to:

* Reliably deploy web application to any number of machines simultaneously,
   in sequence or as a rolling set
* To automate audits of any number of machines (checking login logs,
  enumerating uptimes, and/or applying security patches)
* To script arbitrary workflows over SSH
* To automate common tasks in software teams.
* To drive infrastructure provisioning tools such as *chef-solo*, *Ansible* or similar.

Capistrano is also *very* scriptable, and can be integrated with any other
Ruby software to form part of a larger tool.

#### What does it look like?

![Capistrano 3.5 / Airbrussh formatter screenshot](/images/airbrussh-screenshot.png)


#### What else is in the box?

There's lots of cool stuff in the Capistrano toy box:

* Interchangeable output formatters (progress, pretty, html, etc)
* Easy to add support for other source control management software.
* A rudimentary multi-console for running Capistrano interactively.
* Host and Role filters for partial deploys, or partial-cluster maintenance.
* Recipes for the Rails asset pipelines, and database migrations.
* Support for complex environments.
* A sane, expressive API:

```ruby
desc "Show off the API"
task :ditty do

  on roles(:all) do |host|
    # Capture output from the remote host, and re-use it
    # we can reflect on the `host` object passed to the block
    # and use the `info` logger method to benefit from the
    # output formatter that is selected.
    uptime = capture('uptime')
    if host.roles.include?(:web)
      info "Your webserver #{host} has uptime: #{uptime}"
    end
  end

  on roles(:app) do
    # We can set environmental variables for the duration of a block
    # and move the process into a directoy, executing arbitrary tasks
    # such as letting Rails do some heavy lifting.
    with({:rails_env => :production}) do
      within('/var/www/my/rails/app') do
        execute :rails, :runner, 'MyModel.something'
      end
    end
  end

  on roles(:db) do
    # We can even switch users, provided we have support on the remote
    # server for switching to that user without being prompted for a
    # passphrase.
    as 'postgres' do
      widgets = capture "echo 'SELECT * FROM widgets;' | psql my_database"
      if widgets.to_i < 50
        warn "There are fewer than 50 widgets in the database on #{host}!"
      end
    end
  end

  on roles(:all) do
    # We can even use `test` the way the Unix gods intended
    if test("[ -d /some/directory ]")
      info "Phew, it's ok, the directory exists!"
    end
  end
end
```
