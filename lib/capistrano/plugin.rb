require "capistrano/all"
require "rake/tasklib"

# IMPORTANT: The Capistrano::Plugin system is not yet considered a stable,
# public API, and is subject to change without notice. Eventually it will be
# officially documented and supported, but for now, use it at your own risk.
#
# Base class for Capistrano plugins. Makes building a Capistrano plugin as easy
# as writing a `Capistrano::Plugin` subclass and overriding any or all of its
# three template methods:
#
# * set_defaults
# * register_hooks
# * define_tasks
#
# Within the plugin you can use any methods of the Rake or Capistrano DSLs, like
# `fetch`, `invoke`, etc. In cases when you need to use SSHKit's backend outside
# of an `on` block, use the `backend` convenience method. E.g. `backend.test`,
# `backend.execute`, or `backend.capture`.
#
# Package up and distribute your plugin class as a gem and you're good to go!
#
# To use a plugin, all a user has to do is install it in the Capfile, like this:
#
#   # Capfile
#   require "capistrano/superfancy"
#   install_plugin Capistrano::Superfancy
#
# Or, to install the plugin without its hooks:
#
#   # Capfile
#   require "capistrano/superfancy"
#   install_plugin Capistrano::Superfancy, load_hooks: false
#
class Capistrano::Plugin < Rake::TaskLib
  include Capistrano::DSL

  # Implemented by subclasses to provide default values for settings needed by
  # this plugin. Typically done using the `set_if_empty` Capistrano DSL method.
  #
  # Example:
  #
  #   def set_defaults
  #     set_if_empty :my_plugin_option, true
  #   end
  #
  def set_defaults; end

  # Implemented by subclasses to hook into Capistrano's deployment flow using
  # using the `before` and `after` DSL methods. Note that `register_hooks` will
  # not be called if the user has opted-out of hooks when installing the plugin.
  #
  # Example:
  #
  #   def register_hooks
  #     after "deploy:updated", "my_plugin:do_something"
  #   end
  #
  def register_hooks; end

  # Implemented by subclasses to define Rake tasks. Typically a plugin will call
  # `eval_rakefile` to load Rake tasks from a separate .rake file.
  #
  # Example:
  #
  #   def define_tasks
  #     eval_rakefile File.expand_path("../tasks.rake", __FILE__)
  #   end
  #
  # For simple tasks, you can define them inline. No need for a separate file.
  #
  #   def define_tasks
  #     desc "Do something fantastic."
  #     task "my_plugin:fantastic" do
  #       ...
  #     end
  #   end
  #
  def define_tasks; end

  private

  # Read and eval a .rake file in such a way that `self` within the .rake file
  # refers to this plugin instance. This gives the tasks in the file access to
  # helper methods defined by the plugin.
  def eval_rakefile(path)
    contents = IO.read(path)
    instance_eval(contents, path, 1)
  end

  # Convenience to access the current SSHKit backend outside of an `on` block.
  def backend
    SSHKit::Backend.current
  end
end
