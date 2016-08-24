---
title: Flow
layout: default
---

Capistrano v3 provides a default **deploy flow** and a **rollback flow**:

### Deploy flow

When you run `cap production deploy`, it invokes the following tasks in
sequence:

```ruby
deploy:starting    - start a deployment, make sure everything is ready
deploy:started     - started hook (for custom tasks)
deploy:updating    - update server(s) with a new release
deploy:updated     - updated hook
deploy:publishing  - publish the new release
deploy:published   - published hook
deploy:finishing   - finish the deployment, clean up everything
deploy:finished    - finished hook
```

Notice there are several hook tasks e.g. `:started`, `:updated` for
you to hook up custom tasks into the flow using `after()` and `before()`.

### Rollback flow

When you run `cap production deploy:rollback`, it invokes the following
tasks in sequence:

```ruby
deploy:starting
deploy:started
deploy:reverting           - revert server(s) to previous release
deploy:reverted            - reverted hook
deploy:publishing
deploy:published
deploy:finishing_rollback  - finish the rollback, clean up everything
deploy:finished
```

As you can see, rollback flow shares many tasks with deploy flow. But note
that, rollback flow runs  its own `:finishing_rollback` task because its
cleanup process is usually different from deploy flow.

### Flow examples

Assume you require the following files in `Capfile`,

```ruby
# Capfile
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
```

When you run `cap production deploy`, it runs these tasks:

```ruby
deploy
  deploy:starting
    [before]
      deploy:ensure_stage
      deploy:set_shared_assets
    deploy:check
  deploy:started
  deploy:updating
    git:create_release
    deploy:symlink:shared
  deploy:updated
    [before]
      deploy:bundle
    [after]
      deploy:migrate
      deploy:compile_assets
      deploy:normalize_assets
  deploy:publishing
    deploy:symlink:release
  deploy:published
  deploy:finishing
    deploy:cleanup
  deploy:finished
    deploy:log_revision
```

For `cap production deploy:rollback`, it runs these tasks:

```ruby
deploy
  deploy:starting
    [before]
      deploy:ensure_stage
      deploy:set_shared_assets
    deploy:check
  deploy:started
  deploy:reverting
    deploy:revert_release
  deploy:reverted
    [after]
      deploy:rollback_assets
  deploy:publishing
    deploy:symlink:release
  deploy:published
  deploy:finishing_rollback
    deploy:cleanup_rollback
  deploy:finished
    deploy:log_revision
```
