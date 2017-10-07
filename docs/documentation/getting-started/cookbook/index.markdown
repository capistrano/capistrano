---
title: Task Cookbook
layout: default
---

This page documents common custom tasks for specific use cases. It is hoped that these will be copied and modified for your use case, and also provide a basis for understanding how to extend Capistrano for your own usage.

You can also look in most Capistrano repositories (including core) for rake tasks to see further example of how it works.

Feel free to contribute more via a Pull Request.

## Rails

Many of these tasks probably require [Capistrano::Rails](https://github.com/capistrano/rails).

### Run arbitrary rake tasks from environment variables

From [Capistrano/Rails PR #209](https://github.com/capistrano/rails/pull/209)

```ruby
namespace :ruby do
  desc 'Runs any rake task, cap deploy:rake task=db:rollback'
  task rake: [:set_rails_env] do
    on release_roles([:db]) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, ENV['task']
        end
      end
    end
  end
end
```

Passes in the rake task to be run via an environment variable. Also a simple example of running a rake task on the server.


### Conditional migrations

Arising from [Capistrano/Rails issue #199](https://github.com/capistrano/rails/issues/199)

A frequent issue on deploy are slow migrations which involve downtime. In this case, you often want to run the migrations conditionally, where the main deploy doesn't run them, but you can do so manually at a better point. To do so, you could put the following in your `Capfile`:

```ruby
if ENV['RUN_MIGRATIONS'].present?
  require 'capistrano/rails/migrations'
end
```

Now the migrations do not run by default, but they will run with the following command:

```bash
RUN_MIGRATIONS=true bundle exec cap production deploy:migrate
```
