---
title: Tasks
layout: default
---

```ruby
server 'example.com', roles: [:web, :app]
server 'example.org', roles: [:db, :workers]
desc "Report Uptimes"
task :uptime do
  on roles(:all) do |host|
    execute :any_command, "with args", :here, "and here"
    info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
  end
end
```

**Note**:

**tl;dr**: `execute(:bundle, :install)` and `execute('bundle install')` don't behave identically!

`execute()` has a subtle behaviour. When calling `within './directory' { execute(:bundle, :install) }` for example, the first argument to `execute()` is a *Stringish* with ***no whitespace***. This allows the command to pass through the [SSHKit::CommandMap](https://github.com/capistrano/sshkit#the-command-map) which enables a number of powerful features.

When the first argument to `execute()` contains whitespace, for example `within './directory' { execute('bundle install') }` (or when using a heredoc), neither Capistrano, nor SSHKit can reliably predict how it should be shell escaped, and thus cannot perform any context, or command mapping, that means that the `within(){}` (as well as `with()`, `as()`, etc) have no effect. There have been a few attempts to resolve this, but we don't consider it a bug although we acknowledge that it might be a little counter intuitive.
