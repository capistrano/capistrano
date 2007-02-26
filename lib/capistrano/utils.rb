module Capistrano
  # A helper method for converting a comma-delimited string into an array of
  # roles.
  def self.str2roles(string)
    list = string.split(/,/).map { |s| s.strip.to_sym }
    list.empty? ? nil : list
  end

  # Used by third-party task bundles to identify the capistrano configuration
  # that is loading them. It's return value is not reliable in other contexts.
  # If +require_config+ is not false, an exception will be raised if the current
  # configuration is not set.
  def self.configuration(require_config=false)
    warn "[DEPRECATION] please use Capistrano::Configuration.instance instead of Capistrano.configuration. (You may be using a Capistrano plugin that is using this deprecated syntax.)"
    Capistrano::Configuration.instance(require_config)
  end

  # Used internally by Capistrano to specify the current configuration before
  # loading a third-party task bundle.
  def self.configuration=(config)
    warn "[DEPRECATION] please us Capistrano::Configuration.instance= instead of Capistrano.configuration=."
    Capistrano::Configuration.instance = config
  end
end
