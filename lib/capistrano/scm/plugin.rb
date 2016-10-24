require "capistrano/plugin"
require "capistrano/scm"

# Base class for all built-in and third-party SCM plugins. Notice that this
# class doesn't really do anything other than provide an `scm?` predicate. This
# tells Capistrano that the plugin provides SCM functionality. All other plugin
# features are inherited from Capistrano::Plugin.
#
class Capistrano::SCM::Plugin < Capistrano::Plugin
  def scm?
    true
  end
end
