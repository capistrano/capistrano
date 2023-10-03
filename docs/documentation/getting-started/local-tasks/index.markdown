---
title: Local Tasks
layout: default
---

Local tasks can be run by replacing `on` with `run_locally`:

```ruby
desc 'Notify service of deployment'
task :notify do
  run_locally do
    with rails_env: :development do
      rake 'service:notify'
    end
  end
end
```

**`run_locally` will not execute any task in dry mode. To run tasks whenever dry mode is on please use `run_locally!` instead.**

Of course, you can always just use standard ruby syntax to run things locally:

```ruby
desc 'Notify service of deployment'
task :notify do
  %x(RAILS_ENV=development bundle exec rake "service:notify")
end
```

Alternatively you could use the rake syntax:

```ruby
desc "Notify service of deployment"
task :notify do
   sh 'RAILS_ENV=development bundle exec rake "service:notify"'
end
```
