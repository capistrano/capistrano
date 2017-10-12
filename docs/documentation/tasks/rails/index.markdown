---
title: Custom Rails Tasks
layout: default
---

Many of these tasks probably require [Capistrano::Rails](https://github.com/capistrano/rails).

### Run arbitrary rake tasks from environment variables

From [Capistrano/Rails PR #209](https://github.com/capistrano/rails/pull/209)

```ruby
namespace :deploy do
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

```bash
bundle exec cap production deploy:rake task=db:seed
```


### Conditional migrations

Arising from [Capistrano/Rails issue #199](https://github.com/capistrano/rails/issues/199)

A frequent issue on deploy are slow migrations which involve downtime. In this case, you often want to run the migrations conditionally, where the main deploy doesn't run them, but you can do so manually at a better point. To do so, you could put the following in your `Capfile`:

```ruby
require 'capistrano/rails/migrations' if ENV['RUN_MIGRATIONS']
```

Now the migrations do not run by default, but they will run with the following command:

```bash
RUN_MIGRATIONS=1 bundle exec cap production deploy:migrate
```
