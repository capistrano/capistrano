require "#{File.dirname(__FILE__)}/utils"
# if the following is uncommented, the capistrano gem gets loaded if it is
# installed, for some reason...not sure why :(
# require 'capistrano/configuration'

class ConfigurationTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
  end

  def test_flunk
    flunk
  end
end
