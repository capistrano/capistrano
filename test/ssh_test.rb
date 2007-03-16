require "#{File.dirname(__FILE__)}/utils"
require 'capistrano/ssh'

class SSHTest < Test::Unit::TestCase
  def setup
    @options = { :username => nil,
                 :password => nil,
                 :port     => 22,
                 :auth_methods => %w(publickey hostbased) }
    @server = server("capistrano")
  end

  def test_connect_with_bare_server_without_options_or_config_with_public_key_succeeding_should_only_loop_once
    Net::SSH.expects(:start).with(@server.host, @options).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server)
  end

  def test_connect_with_bare_server_without_options_with_public_key_failing_should_try_password
    Net::SSH.expects(:start).with(@server.host, @options).raises(Net::SSH::AuthenticationFailed)
    Net::SSH.expects(:start).with(@server.host, @options.merge(:password => "f4b13n", :auth_methods => %w(password keyboard-interactive))).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, :password => "f4b13n")
  end

  def test_connect_with_bare_server_without_options_public_key_and_password_failing_should_raise_error
    Net::SSH.expects(:start).with(@server.host, @options).raises(Net::SSH::AuthenticationFailed)
    Net::SSH.expects(:start).with(@server.host, @options.merge(:password => "f4b13n", :auth_methods => %w(password keyboard-interactive))).raises(Net::SSH::AuthenticationFailed)
    assert_raises(Net::SSH::AuthenticationFailed) do
      Capistrano::SSH.connect(@server, :password => "f4b13n")
    end
  end

  def test_connect_with_bare_server_and_user_via_public_key_should_pass_user_to_net_ssh
    Net::SSH.expects(:start).with(@server.host, @options.merge(:username => "jamis")).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, :user => "jamis")
  end

  def test_connect_with_bare_server_and_user_via_password_should_pass_user_to_net_ssh
    Net::SSH.expects(:start).with(@server.host, @options.merge(:username => "jamis")).raises(Net::SSH::AuthenticationFailed)
    Net::SSH.expects(:start).with(@server.host, @options.merge(:username => "jamis", :password => "f4b13n", :auth_methods => %w(password keyboard-interactive))).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, :user => "jamis", :password => "f4b13n")
  end

  def test_connect_with_bare_server_with_explicit_port_should_pass_port_to_net_ssh
    Net::SSH.expects(:start).with(@server.host, @options.merge(:port => 1234)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, :port => 1234)
  end

  def test_connect_with_server_with_user_should_pass_user_to_net_ssh
    server = server("jamis@capistrano")
    Net::SSH.expects(:start).with(server.host, @options.merge(:username => "jamis")).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(server)
  end

  def test_connect_with_server_with_port_should_pass_port_to_net_ssh
    server = server("capistrano:1235")
    Net::SSH.expects(:start).with(server.host, @options.merge(:port => 1235)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(server)
  end

  def test_connect_with_server_with_user_and_port_should_pass_user_and_port_to_net_ssh
    server = server("jamis@capistrano:1235")
    Net::SSH.expects(:start).with(server.host, @options.merge(:username => "jamis", :port => 1235)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(server)
  end

  def test_connect_with_ssh_options_should_override_options
    ssh_options = { :username => "JamisMan", :port => 8125 }
    Net::SSH.expects(:start).with(@server.host, @options.merge(:username => "JamisMan", :port => 8125)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, {:ssh_options => ssh_options, :user => "jamis", :port => 1235})
  end

  def test_connect_with_ssh_options_should_override_server_options
    ssh_options = { :username => "JamisMan", :port => 8125 }
    server = server("jamis@capistrano:1235")
    Net::SSH.expects(:start).with(server.host, @options.merge(:username => "JamisMan", :port => 8125)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(server, {:ssh_options => ssh_options})
  end

  def test_connect_should_add_real_host_accessor_to_connection
    Net::SSH.expects(:start).with(@server.host, @options).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server)
    assert success.respond_to?(:real_host)
    assert success.respond_to?(:real_host=)
    assert_equal success.real_host, @server.host
  end
end
