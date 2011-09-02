require "utils"
require 'capistrano/configuration/actions/file_transfer'

class ConfigurationActionsFileTransferTest < Test::Unit::TestCase
  class MockConfig
    include Capistrano::Configuration::Actions::FileTransfer
    attr_accessor :sessions, :dry_run
  end

  def setup
    @config = MockConfig.new
    @config.stubs(:logger).returns(stub_everything)
    @config.stubs(:variables).returns({})
  end

  def test_put_should_delegate_to_upload
    @config.expects(:upload).with { |from, to, opts|
      from.string == "some data" && to == "test.txt" && opts == { :mode => 0777 } }
    @config.expects(:run).never
    @config.put("some data", "test.txt", :mode => 0777)
  end

  def test_get_should_delegate_to_download_with_once
    @config.expects(:download).with("testr.txt", "testl.txt", :foo => "bar", :once => true)
    @config.get("testr.txt", "testl.txt", :foo => "bar")
  end

  def test_upload_should_delegate_to_transfer
    @config.expects(:transfer).with(:up, "testl.txt", "testr.txt", :foo => "bar")
    @config.upload("testl.txt", "testr.txt", :foo => "bar")
  end

  def test_upload_without_mode_should_not_try_to_chmod
    @config.expects(:transfer).with(:up, "testl.txt", "testr.txt", :foo => "bar")
    @config.expects(:run).never
    @config.upload("testl.txt", "testr.txt", :foo => "bar")
  end

  def test_upload_with_mode_should_try_to_chmod
    @config.expects(:transfer).with(:up, "testl.txt", "testr.txt", :foo => "bar")
    @config.expects(:run).with("chmod 775 testr.txt", {:foo => "bar"})
    @config.upload("testl.txt", "testr.txt", :mode => 0775, :foo => "bar")
  end

  def test_upload_with_symbolic_mode_should_try_to_chmod
    @config.expects(:transfer).with(:up, "testl.txt", "testr.txt", :foo => "bar")
    @config.expects(:run).with("chmod g+w testr.txt", {:foo => "bar"})
    @config.upload("testl.txt", "testr.txt", :mode => "g+w", :foo => "bar")
  end

  def test_download_should_delegate_to_transfer
    @config.expects(:transfer).with(:down, "testr.txt", "testl.txt", :foo => "bar")
    @config.download("testr.txt", "testl.txt", :foo => "bar")
  end

  def test_transfer_should_invoke_transfer_on_matching_servers
    @config.sessions = { :a => 1, :b => 2, :c => 3, :d => 4 }
    @config.expects(:execute_on_servers).with(:foo => "bar").yields([:a, :b, :c])
    Capistrano::Transfer.expects(:process).with(:up, "testl.txt", "testr.txt", [1,2,3], {:foo => "bar", :logger => @config.logger})
    @config.transfer(:up, "testl.txt", "testr.txt", :foo => "bar")
  end

  def test_transfer_should_not_override_via_when_transfer_via_variable_not_set
    @config.stubs(:execute_on_servers).yields([])
    @config.expects(:variables).returns({})
    Capistrano::Transfer.expects(:process).with(anything, anything, anything, anything, {:logger => @config.logger})
    @config.transfer(anything, anything, anything)
  end

  def test_transfer_should_override_via_when_transfer_via_variable_set
    @config.stubs(:execute_on_servers).yields([])
    @config.expects(:variables).returns({:transfer_via => :foo})
    Capistrano::Transfer.expects(:process).with(anything, anything, anything, anything, {:via => :foo, :logger => @config.logger})
    @config.transfer(anything, anything, anything)
  end
end
