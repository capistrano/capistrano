require "#{File.dirname(__FILE__)}/utils"

class ConfigurationTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
  end

  def test_flunk
    flunk
  end
end
