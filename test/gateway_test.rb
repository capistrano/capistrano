require "#{File.dirname(__FILE__)}/utils"
require 'capistrano/gateway'

class GatewayTest < Test::Unit::TestCase
  def teardown
    Thread.list { |t| t.kill unless Thread.current == t }
  end

  def test_initialize_should_open_and_set_session_value
    run_test_initialize_should_open_and_set_session_value
  end

  def test_initialize_when_connect_lags_should_open_and_set_session_value
    run_test_initialize_should_open_and_set_session_value do |expects|
      expects.with { |*args| sleep 0.2; true }
    end
  end

  def test_shutdown_without_any_open_connections_should_terminate_session
    gateway = new_gateway
    gateway.shutdown!
    assert !gateway.thread.alive?
    assert !gateway.session.looping?
  end

  def test_connect_to_should_start_local_ports_at_65535
    gateway = new_gateway
    expect_connect_to(:host => "127.0.0.1", :port => 65535).returns(result = sess_with_xserver("app1"))
    newsess = gateway.connect_to(server("app1"))
    assert_equal result, newsess
    assert_equal [65535, "app1", 22], gateway.session.forward.active_locals[65535]
  end

  def test_connect_to_should_decrement_port_and_retry_if_ports_are_in_use
    gateway = new_gateway(:reserved => lambda { |n| n > 65000 })
    expect_connect_to(:host => "127.0.0.1", :port => 65000).returns(result = sess_with_xserver("app1"))
    newsess = gateway.connect_to(server("app1"))
    assert_equal result, newsess
    assert_equal [65000, "app1", 22], gateway.session.forward.active_locals[65000]
  end

  def test_connect_to_should_honor_user_specification_in_server_definition
    gateway = new_gateway
    expect_connect_to(:host => "127.0.0.1", :user => "jamis", :port => 65535).returns(result = sess_with_xserver("app1"))
    newsess = gateway.connect_to(server("jamis@app1"))
    assert_equal result, newsess
    assert_equal [65535, "app1", 22], gateway.session.forward.active_locals[65535]
  end

  def test_connect_to_should_honor_port_specification_in_server_definition
    gateway = new_gateway
    expect_connect_to(:host => "127.0.0.1", :port => 65535).returns(result = sess_with_xserver("app1"))
    newsess = gateway.connect_to(server("app1:1234"))
    assert_equal result, newsess
    assert_equal [65535, "app1", 1234], gateway.session.forward.active_locals[65535]
  end

  def test_connect_to_should_set_xserver_to_tunnel_target
    gateway = new_gateway
    expect_connect_to(:host => "127.0.0.1", :port => 65535).returns(result = sess_with_xserver("app1"))
    newsess = gateway.connect_to(server("app1:1234"))
    assert_equal result, newsess
  end

  def test_shutdown_should_cancel_active_forwarded_ports
    gateway = new_gateway
    expect_connect_to(:host => "127.0.0.1", :port => 65535).returns(sess_with_xserver("app1"))
    gateway.connect_to(server("app1"))
    assert !gateway.session.forward.active_locals.empty?
    gateway.shutdown!
    assert gateway.session.forward.active_locals.empty?
  end

  def test_error_while_connecting_should_cause_connection_to_fail
    gateway = new_gateway
    expect_connect_to(:host => "127.0.0.1").raises(RuntimeError)
    gateway.expects(:warn).times(2)
    assert_raises(Capistrano::ConnectionError) { gateway.connect_to(server("app1")) }
  end
  
  def test_connection_error_should_include_accessor_with_host_array
    gateway = new_gateway
    expect_connect_to(:host => "127.0.0.1").raises(RuntimeError)
    gateway.expects(:warn).times(2)
  
    begin
      gateway.connect_to(server("app1"))
      flunk "expected an exception to be raised"
    rescue Capistrano::ConnectionError => e
      assert e.respond_to?(:hosts)
      assert_equal %w(app1), e.hosts.map { |h| h.to_s }
    end
  end

  private

    def sess_with_xserver(host)
      s = server(host)
      sess = mock("session")
      sess.expects(:xserver=).with { |v| v.host == host }
      sess
    end

    def expect_connect_to(options={})
      Capistrano::SSH.expects(:connect).with do |server,config|
        options.all? do |key, value|
          case key
          when :host then server.host == value
          when :user then server.user == value
          when :port then server.port == value
          else false
          end
        end
      end
    end

    def new_gateway(options={})
      expect_connect_to(:host => "capistrano").yields(MockSession.new(options))
      Capistrano::Gateway.new(server("capistrano"))
    end

    def run_test_initialize_should_open_and_set_session_value
      session = mock("Net::SSH session")
      session.expects(:loop)
      expectation = Capistrano::SSH.expects(:connect).yields(session)
      yield expectation if block_given?
      gateway = Capistrano::Gateway.new(server("capistrano"))
      gateway.thread.join
      assert_equal session, gateway.session
    end

    class MockForward
      attr_reader :active_locals

      def initialize(options)
        @options = options
        @active_locals = {}
      end

      def cancel_local(port)
        @active_locals.delete(port)
      end

      def local(lport, host, rport)
        raise Errno::EADDRINUSE if @options[:reserved] && @options[:reserved][lport]
        @active_locals[lport] = [lport, host, rport]
      end
    end

    class MockSession
      attr_reader :forward

      def initialize(options={})
        @forward = MockForward.new(options)
      end

      def looping?
        @looping
      end

      def loop
        @looping = true
        sleep 0.1 while yield
        @looping = false
      end
    end
end