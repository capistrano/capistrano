$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'test/unit'
require 'capistrano/server_definition'

class ServerDefinitionTest < Test::Unit::TestCase
  def test_new_without_credentials_or_port_should_set_values_to_defaults
    server = Capistrano::ServerDefinition.new("www.capistrano.test")
    assert_equal "www.capistrano.test", server.host
    assert_nil   server.user
    assert_nil   server.port
  end

  def test_new_with_encoded_user_should_extract_user_and_use_default_port
    server = Capistrano::ServerDefinition.new("jamis@www.capistrano.test")
    assert_equal "www.capistrano.test", server.host
    assert_equal "jamis", server.user
    assert_nil   server.port
  end

  def test_new_with_encoded_port_should_extract_port_and_use_default_user
    server = Capistrano::ServerDefinition.new("www.capistrano.test:8080")
    assert_equal "www.capistrano.test", server.host
    assert_nil   server.user
    assert_equal 8080, server.port
  end

  def test_new_with_encoded_user_and_port_should_extract_user_and_port
    server = Capistrano::ServerDefinition.new("jamis@www.capistrano.test:8080")
    assert_equal "www.capistrano.test", server.host
    assert_equal "jamis", server.user
    assert_equal 8080, server.port
  end

  def test_new_with_user_as_option_should_use_given_user
    server = Capistrano::ServerDefinition.new("www.capistrano.test", :user => "jamis")
    assert_equal "www.capistrano.test", server.host
    assert_equal "jamis", server.user
    assert_nil   server.port
  end

  def test_new_with_port_as_option_should_use_given_user
    server = Capistrano::ServerDefinition.new("www.capistrano.test", :port => 8080)
    assert_equal "www.capistrano.test", server.host
    assert_nil   server.user
    assert_equal 8080, server.port
  end

  def test_new_with_option_should_override_encoded_value_and_remove_from_options
    server = Capistrano::ServerDefinition.new("jamis@www.capistrano.test:8080", :user => "david", :port => 8081)
    assert_equal "www.capistrano.test", server.host
    assert_equal "david", server.user
    assert_equal 8081, server.port
    assert server.options.empty?
  end

  def test_new_with_option_should_dup_option_hash
    options = {}
    server = Capistrano::ServerDefinition.new("www.capistrano.test", options)
    assert_not_equal options.object_id, server.options.object_id
  end

  def test_new_with_options_should_keep_options
    server = Capistrano::ServerDefinition.new("www.capistrano.test", :primary => true)
    assert_equal true, server.options[:primary]
  end
end