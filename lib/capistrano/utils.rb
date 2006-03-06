module SwitchTower
  # A helper method for converting a comma-delimited string into an array of
  # roles.
  def self.str2roles(string)
    list = string.split(/,/).map { |s| s.strip.to_sym }
    list.empty? ? nil : list
  end

  # Used by third-party task bundles to identify the switchtower configuration
  # that is loading them. It's return value is not reliable in other contexts.
  # If +require_config+ is not false, an exception will be raised if the current
  # configuration is not set.
  def self.configuration(require_config=false)
    config = Thread.current[:switchtower_configuration]
    if require_config && config.nil?
      raise "Please require this file from within a SwitchTower recipe"
    end
    config
  end

  # Used internally by SwitchTower to specify the current configuration before
  # loading a third-party task bundle.
  def self.configuration=(config)
    Thread.current[:switchtower_configuration] = config
  end
end