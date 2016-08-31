---
title: Remote commands with SSH Kit
layout: default
---

Capistrano executes commands on remote servers using [**SSHKit**](https://github.com/capistrano/sshkit).

An example setting a working directory, user and environment variable:

```ruby
on roles(:app), in: :sequence, wait: 5 do
  within "/opt/sites/example.com" do
    # commands in this block execute in the
    # directory: /opt/sites/example.com
    as :deploy  do
      # commands in this block execute as the "deploy" user.
      with rails_env: :production do
        # commands in this block execute with the environment
        # variable RAILS_ENV=production
        rake   "assets:precompile"
        runner "S3::Sync.notify"
      end
    end
  end
end
```

For more examples, see the EXAMPLES.md file in the [**SSHKit**](https://github.com/capistrano/sshkit) project:

[https://github.com/capistrano/sshkit/blob/master/EXAMPLES.md](https://github.com/capistrano/sshkit/blob/master/EXAMPLES.md)
