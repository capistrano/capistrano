require "#{File.dirname(__FILE__)}/utils"
require 'capistrano/configuration'

# These tests are only for testing the integration of the various components
# of the Configuration class. To test specific features, please look at the
# tests under test/configuration.

class ConfigurationTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
  end

  def test_connections_execution_loading_namespaces_roles_and_variables_modules_should_integrate_correctly
    Capistrano::SSH.expects(:connect).with { |s,c| s.host == "www.capistrano.test" && c == @config }.returns(:session)
    Capistrano::Command.expects(:process).with("echo 'hello world'", [:session], :logger => @config.logger)

    @config.load do
      role :test, "www.capistrano.test"
      set  :message, "hello world"
      namespace :testing do
        task :example, :roles => :test do
          run "echo '#{message}'"
        end
      end
    end

    @config.testing.example
  end
end
