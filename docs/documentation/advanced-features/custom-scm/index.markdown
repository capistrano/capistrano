---
title: Custom SCM
layout: default
---

Capistrano uses what it calls "SCM plugins" (Source Code Management), to deploy
your source code from a central repository. Out of the box, Capistrano has three
plugins to handle Git, Subversion, and Mercurial repositories.

Most Capistrano users are well-served by these default implementations. To
choose an SCM, users add it to their Capfile, like this:

```ruby
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git
```

It is also possible to provide a custom SCM plugin, in order to change how
Capistrano checks out your application's source code. SCM plugins can be
packaged as Ruby gems and distributed to other users.

This document is a short guide to writing your own plugin. *It applies to
Capistrano 3.7.0 and newer.*

### 1. Write a Ruby class that extends Capistrano::SCM::Plugin

Let's say you want to create a "Foo" SCM. You'll need to write a plugin class,
like this:

```ruby
require "capistrano/scm/plugin"

# By convention, Capistrano plugins are placed in the
# Capistrano namespace. This is completely optional.
module Capistrano
  class FooPlugin < ::Capistrano::SCM::Plugin
    def set_defaults
      # Define any variables needed to configure the plugin.
      # set_if_empty :myvar, "my-default-value"
    end
  end
end
```

### 2. Implement a create_release task

When the user runs `cap deploy`, your SCM is responsible for creating the
release directory and copying the application source code into it. You need to
do this using a task that is registered to run after `deploy:new_release_path`.

By convention (not a requirement), this task is called `create_release`.

Inside your plugin class, use the `define_tasks` and `register_hooks` methods
like this:

```ruby
def define_tasks
  # The namespace can be whatever you want, but its best
  # to choose a name that matches your plugin name.
  namespace :foo do
    task :create_release do
      # Your code to create the release directory and copy
      # the source code into it goes here.
      on release_roles :all do
        execute :mkdir, "-p", release_path
        # ...
      end
    end
  end
end

def register_hooks
  # Tell Capistrano to run the custom create_release task
  # during deploy.
  after "deploy:new_release_path", "foo:create_release"
end
```

### 3. Implement the set_current_revision task

Similar to how you defined a `create_release`, you should also define a
`set_current_revision` task. The purpose of this task is to set a special
variable that Capistrano uses to write to the deployment log.

```ruby
# Your task should do something like this
set :current_revision, "..."

# Register this hook to ensure your task runs
before "deploy:set_current_revision", "foo:set_current_revision"
```

### 4. Use the plugin

To use your plugin, simply `require` the file where your plugin class is
defined, and then use `install_plugin`.

```ruby
# In Capfile
require_relative "path/to/foo_plugin.rb"
install_plugin Capistrano::FooPlugin
```

That's it!

### 5. Distribute your plugin as a gem

Packaging and distributing Ruby gems is outside the scope of this document.
However, there is nothing Capistrano-specific that needs to be done here; just
create a standard gem that contains your plugin class.

Users can then install your plugin by adding its gem to their Gemfile:

```ruby
gem "your-gem-name", :group => :development
```

And then add it the Capfile:

```ruby
require "your-gem-name"
install_plugin YourPluginClass
```

### 6. Getting help

For more techniques and ideas, check out the implementations of the default Git,
Subversion, and Mercurial plugins in the official
[Capistrano repository](https://github.com/capistrano/capistrano) on GitHub.
All three follow the same patterns described in this document.

Otherwise open a [GitHub issue](https://github.com/capistrano/capistrano/issues)
with your questions or feedback. Thanks!
