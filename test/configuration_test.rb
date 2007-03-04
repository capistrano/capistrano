require "#{File.dirname(__FILE__)}/utils"
require 'capistrano/configuration'

# These tests are only for testing the integration of the various components
# of the Configuration class. To test specific features, please look at the
# tests under test/configuration.

class ConfigurationTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
  end

  def test_flunk
    flunk
  end
end
