# Encapsulates the logic for installing plugins into Capistrano. Plugins must
# simply conform to a basic API; the PluginInstaller takes care of invoking the
# API at appropriate times.
#
# This class is not used directly; instead it is typically accessed via the
# `install_plugin` method of the Capistrano DSL.
#
module Capistrano
  class Configuration
    class PluginInstaller
      # "Installs" a Plugin into Capistrano by loading its tasks, hooks, and
      # defaults at the appropriate time. The hooks in particular can be
      # skipped, if you want full control over when and how the plugin's tasks
      # are executed. Simply pass `load_hooks:false` to opt out.
      #
      # The plugin class or instance may be provided. These are equivalent:
      #
      # install(Capistrano::SCM::Git)
      # install(Capistrano::SCM::Git.new)
      #
      def install(plugin, load_hooks: true)
        plugin = plugin.is_a?(Class) ? plugin.new : plugin

        plugin.define_tasks
        plugin.register_hooks if load_hooks

        Rake::Task.define_task("load:defaults") do
          plugin.set_defaults
        end
      end
    end
  end
end
