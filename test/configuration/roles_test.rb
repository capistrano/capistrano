require "#{File.dirname(__FILE__)}/../utils"
require 'capistrano/configuration/roles'

class ConfigurationRolesTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :original_initialize_called

    def initialize
      @original_initialize_called = true
    end

    include Capistrano::Configuration::Roles
  end

  def setup
    @config = MockConfig.new
  end

  def test_initialize_should_initialize_roles_collection
    assert @config.original_initialize_called
    assert @config.roles.empty?
  end

  def test_role_should_allow_empty_list
    @config.role :app
    assert @config.roles[:app].empty?
  end

  def test_role_with_one_argument_should_add_to_roles_collection
    @config.role :app, "app1.capistrano.test"
    assert_equal [:app], @config.roles.keys
    assert_equal %w(app1.capistrano.test), @config.roles[:app].map { |s| s.host }
  end

  def test_role_with_multiple_arguments_should_add_each_to_roles_collection
    @config.role :app, "app1.capistrano.test", "app2.capistrano.test"
    assert_equal [:app], @config.roles.keys
    assert_equal %w(app1.capistrano.test app2.capistrano.test), @config.roles[:app].map { |s| s.host }
  end

  def test_role_with_options_should_apply_options_to_each_argument
    @config.role :app, "app1.capistrano.test", "app2.capistrano.test", :extra => :value
    @config.roles[:app].each do |server|
      assert_equal({:extra => :value}, server.options)
    end
  end
end