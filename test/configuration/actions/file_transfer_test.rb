require "#{File.dirname(__FILE__)}/../../utils"
require 'capistrano/configuration/actions/file_transfer'

class ConfigurationActionsFileTransferTest < Test::Unit::TestCase
  class MockConfig
    include Capistrano::Configuration::Actions::FileTransfer
  end

  def setup
    @config = MockConfig.new
    @config.stubs(:logger).returns(stub_everything)
  end

  def test_put_should_pass_options_to_execute_on_servers
    @config.expects(:execute_on_servers).with(:foo => "bar")
    @config.put("some data", "test.txt", :foo => "bar")
  end

  def test_put_should_delegate_to_Upload_process
    @config.expects(:execute_on_servers).yields(%w(s1 s2 s3).map { |s| mock(:host => s) })
    @config.expects(:sessions).times(3).returns(Hash.new{|h,k| h[k] = k.host.to_sym})
    Capistrano::Upload.expects(:process).with([:s1,:s2,:s3], "test.txt", :data => "some data", :mode => 0777, :logger => @config.logger)
    @config.put("some data", "test.txt", :mode => 0777)
  end

  def test_get_should_pass_options_execute_on_servers_including_once
    @config.expects(:execute_on_servers).with(:foo => "bar", :once => true)
    @config.get("test.txt", "test.txt", :foo => "bar")
  end

  def test_get_should_use_sftp_get_file_to_local_path
    sftp = mock("sftp", :state => :closed, :connect => true)
    sftp.expects(:get_file).with("remote.txt", "local.txt")

    s = server("capistrano")
    @config.expects(:execute_on_servers).yields([s])
    @config.expects(:sessions).returns(s => mock("session", :sftp => sftp))
    @config.get("remote.txt", "local.txt")
  end
end