---
title: User Input
layout: default
---

User input can be required in a task or during configuration:

```ruby
# used in a configuration
set :database_name, ask(:database_name, "default_database_name")

# used in a task
desc "Ask about breakfast"
task :breakfast do
  ask(:breakfast, "pancakes")
  on roles(:all) do |h|
    execute "echo \"$(whoami) wants #{fetch(:breakfast)} for breakfast!\""
  end
end
```

When using `ask` to get user input, you can pass `echo: false` to prevent the
input from being displayed. This option should be used to ask the user for
passwords and other sensitive data during a deploy run.

```ruby
set :database_password, ask(:database_password, 'default_password', echo: false)
```


The symbol passed as a parameter will be printed as text for the user and the
input will be saved to this variable:

```ruby
ask(:database_encoding, 'UTF-8')
# Please enter :database_encoding (UTF-8):

fetch(:database_encoding)
# => contains the user input (or the default)
#    once the above line got executed
```


You can use `ask` to set a server- or role-specific configuration variable.

```ruby
set :password, ask(:password, nil)
server 'example.com', user: 'ssh_user_name', port: 22, password: fetch(:password), roles: %w{web app db}
```
