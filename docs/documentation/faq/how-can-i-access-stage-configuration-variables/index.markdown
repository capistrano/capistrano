---
title: How can I access stage configuration variables?
layout: default
---

Configuration variables are access with the fetch method, like so:

```ruby
local = fetch(:configuration_variable, _default_value_)
```

This works fine when accessing configuration variables defined within the same file.  For example accessing a previously set configuration variable defined in deploy.rb or accessing a set configuration variable in a stage file.

The deploy.rb configuration is executed first and then the stage file(s) from config/deploy/*.rb are executed next.  This means that the configuration variables set in deploy.rb are available to the stage files, but configuration variables created in a stage file are not available in deploy.rb.  To access them they must be lazily loaded in deploy.rb.  This works because all configuration variables (from both deploy.rb and the current stage file) have been defined by the time the tasks run and access the variables.

For example, let's create a configuration variable in the production and staging files and access the current one from deploy.rb.

config/deploy/production.rb

```ruby
set :app_domain, "www.my_application.com"
```

config/deploy/staging.rb

```ruby
set :app_domain, "stage.application_test.com"
```

These variables are not available in deploy.rb using `fetch(:nginx_port)` or `fetch(:app_domain)` because they are not defined when deploy.rb is executed.  They can, however, be lazily loaded using a lambda in deploy.rb like this:

config/deploy.rb

```ruby
set :nginx_server_name, ->{ fetch(:app_domain) }
set :puma_bind, ->{ "unix:/tmp/#{fetch(:app_domain)}.sock" }
```

Now the `:nginx_server_name` and `:puma_bind` variables will be lazily assigned the values set in which ever stage file was used to deploy.

If you need to create nested hashes, you might find `do/end` syntax more readable:

```ruby
set :database_yml, -> do
  {
    production: {
      host: 'localhost'
    }
  }
end
```
