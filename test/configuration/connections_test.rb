require "#{File.dirname(__FILE__)}/../utils"
require 'capistrano/configuration/connections'

class ConfigurationConnectionsTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :original_initialize_called
    attr_reader :values
    attr_accessor :current_task

    def initialize
      @original_initialize_called = true
      @values = {}
    end

    def fetch(*args)
      @values.fetch(*args)
    end

    def [](key)
      @values[key]
    end

    def exists?(key)
      @values.key?(key)
    end

    include Capistrano::Configuration::Connections
  end

  def setup
    @config = MockConfig.new
    @config.stubs(:logger).returns(stub_everything)
    @ssh_options = {
      :user        => "jamis",
      :port        => 8080,
      :password    => "g00b3r",
      :ssh_options => { :debug => :verbose }
    }
  end

  def test_initialize_should_initialize_collections_and_call_original_initialize
    assert @config.original_initialize_called
    assert @config.sessions.empty?
  end

  def test_connection_factory_should_return_default_connection_factory_instance
    factory = @config.connection_factory
    assert_instance_of Capistrano::Configuration::Connections::DefaultConnectionFactory, factory
  end

  def test_connection_factory_instance_should_be_cached
    assert_same @config.connection_factory, @config.connection_factory
  end

  def test_default_connection_factory_honors_config_options
    server = server("capistrano")
    Capistrano::SSH.expects(:connect).with(server, @config).returns(:session)
    assert_equal :session, @config.connection_factory.connect_to(server)
  end

  def test_connection_factory_should_return_gateway_instance_if_gateway_variable_is_set
    @config.values[:gateway] = "capistrano"
    server = server("capistrano")
    Capistrano::SSH.expects(:connect).with { |s,| s.host == "capistrano" }.yields(stub_everything)
    assert_instance_of Capistrano::Gateway, @config.connection_factory
  end

  def test_connection_factory_as_gateway_should_honor_config_options
    @config.values[:gateway] = "capistrano"
    @config.values.update(@ssh_options)
    Capistrano::SSH.expects(:connect).with { |s,opts| s.host == "capistrano" && opts == @config }.yields(stub_everything)
    assert_instance_of Capistrano::Gateway, @config.connection_factory
  end

  def test_establish_connections_to_should_accept_a_single_nonarray_parameter
    Capistrano::SSH.expects(:connect).with { |s,| s.host == "capistrano" }.returns(:success)
    assert @config.sessions.empty?
    @config.establish_connections_to(server("capistrano"))
    assert ["capistrano"], @config.sessions.keys
  end

  def test_establish_connections_to_should_accept_an_array
    Capistrano::SSH.expects(:connect).times(3).returns(:success)
    assert @config.sessions.empty?
    @config.establish_connections_to(%w(cap1 cap2 cap3).map { |s| server(s) })
    assert %w(cap1 cap2 cap3), @config.sessions.keys.sort
  end

  def test_establish_connections_to_should_not_attempt_to_reestablish_existing_connections
    Capistrano::SSH.expects(:connect).times(2).returns(:success)
    @config.sessions["cap1"] = :ok
    @config.establish_connections_to(%w(cap1 cap2 cap3).map { |s| server(s) })
    assert %w(cap1 cap2 cap3), @config.sessions.keys.sort
  end

  def test_execute_on_servers_should_require_a_block
    assert_raises(ArgumentError) { @config.execute_on_servers }
  end

  def test_execute_on_servers_without_current_task_should_call_find_servers
    list = [server("first"), server("second")]
    @config.expects(:find_servers).with(:a => :b, :c => :d).returns(list)
    @config.expects(:establish_connections_to).with(list).returns(:done)
    @config.execute_on_servers(:a => :b, :c => :d) do |result|
      assert_equal list, result
    end
  end

  def test_execute_on_servers_without_current_task_should_raise_error_if_no_matching_servers
    @config.expects(:find_servers).with(:a => :b, :c => :d).returns([])
    assert_raises(ScriptError) { @config.execute_on_servers(:a => :b, :c => :d) { |list| } }
  end

  def test_execute_on_servers_should_raise_an_error_if_the_current_task_has_no_matching_servers
    @config.current_task = stub("task", :fully_qualified_name => "name", :options => {})
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([])
    assert_raises(ScriptError) do
      @config.execute_on_servers do
        flunk "should not get here"
      end
    end
  end

  def test_execute_on_servers_should_determine_server_list_from_active_task
    assert @config.sessions.empty?
    @config.current_task = stub("task")
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([server("cap1"), server("cap2"), server("cap3")])
    Capistrano::SSH.expects(:connect).times(3).returns(:success)
    @config.execute_on_servers {}
    assert_equal %w(cap1 cap2 cap3), @config.sessions.keys.sort
  end

  def test_execute_on_servers_should_yield_server_list_to_block
    assert @config.sessions.empty?
    @config.current_task = stub("task")
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([server("cap1"), server("cap2"), server("cap3")])
    Capistrano::SSH.expects(:connect).times(3).returns(:success)
    block_called = false
    @config.execute_on_servers do |servers|
      block_called = true
      assert servers.detect { |s| s.host == "cap1" }
      assert servers.detect { |s| s.host == "cap2" }
      assert servers.detect { |s| s.host == "cap3" }
      assert servers.all? { |s| @config.sessions[s.host] }
    end
    assert block_called
  end

  def test_execute_on_servers_with_once_option_should_establish_connection_to_and_yield_only_the_first_server
    assert @config.sessions.empty?
    @config.current_task = stub("task")
    @config.expects(:find_servers_for_task).with(@config.current_task, :once => true).returns([server("cap1"), server("cap2"), server("cap3")])
    Capistrano::SSH.expects(:connect).returns(:success)
    block_called = false
    @config.execute_on_servers(:once => true) do |servers|
      block_called = true
      assert_equal %w(cap1), servers.map { |s| s.host }
    end
    assert block_called
    assert_equal %w(cap1), @config.sessions.keys.sort
  end

  def test_connect_should_establish_connections_to_all_servers_in_scope
    assert @config.sessions.empty?
    @config.current_task = stub("task")
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([server("cap1"), server("cap2"), server("cap3")])
    Capistrano::SSH.expects(:connect).times(3).returns(:success)
    @config.connect!
    assert_equal %w(cap1 cap2 cap3), @config.sessions.keys.sort
  end

  def test_connect_should_honor_once_option
    assert @config.sessions.empty?
    @config.current_task = stub("task")
    @config.expects(:find_servers_for_task).with(@config.current_task, :once => true).returns([server("cap1"), server("cap2"), server("cap3")])
    Capistrano::SSH.expects(:connect).returns(:success)
    @config.connect! :once => true
    assert_equal %w(cap1), @config.sessions.keys.sort
  end
end