require "#{File.dirname(__FILE__)}/utils"
require 'capistrano/cli'

class CLI_Test < Test::Unit::TestCase
  def setup
    @cli = Capistrano::CLI.new([])
  end

  def test_flunk
    flunk
  end
end
