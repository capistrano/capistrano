require 'capistrano/logger'
require 'capistrano/extensions'
require 'capistrano/configuration/execution'
require 'capistrano/configuration/loading'
require 'capistrano/configuration/namespaces'
require 'capistrano/configuration/roles'
require 'capistrano/configuration/variables'

module Capistrano
  # Represents a specific Capistrano configuration. A Configuration instance
  # may be used to load multiple recipe files, define and describe tasks,
  # define roles, and set configuration variables.
  class Configuration
    # The logger instance defined for this configuration.
    attr_reader :logger

    def initialize #:nodoc:
      @logger = Logger.new
    end

    # The includes must come at the bottom, since they may redefine methods
    # defined in the base class.
    include Execution, Loading, Namespaces, Roles, Variables
  end
end
