require "utils"
require 'capistrano/configuration/actions/inspect'

class ConfigurationActionsInspectTest < Test::Unit::TestCase
  class MockConfig
    include Capistrano::Configuration::Actions::Inspect
  end

  def setup
    @config = MockConfig.new
    @config.stubs(:logger).returns(stub_everything)
    @config.stubs(:sudo).returns('sudo')
  end

  def test_stream_should_pass_options_through_to_run
    @config.expects(:invoke_command).with("tail -f foo.log", :once => true, :eof => true)
    @config.stream("tail -f foo.log", :once => true)
  end

  def test_stream_with_sudo_should_avoid_closing_stdin
    @config.expects(:invoke_command).with("sudo tail -f foo.log", :once => true, :eof => false)
    @config.stream("sudo tail -f foo.log", :once => true)
  end

  def test_stream_should_emit_stdout_via_puts
    @config.expects(:invoke_command).yields(mock("channel"), :out, "something streamed")
    @config.expects(:puts).with("something streamed")
    @config.expects(:warn).never
    @config.stream("tail -f foo.log")
  end

  def test_stream_should_emit_stderr_via_warn
    ch = mock("channel")
    ch.expects(:[]).with(:server).returns(server("capistrano"))
    @config.expects(:invoke_command).yields(ch, :err, "something streamed")
    @config.expects(:puts).never
    @config.expects(:warn).with("[err :: capistrano] something streamed")
    @config.stream("tail -f foo.log")
  end

  def test_capture_should_pass_options_merged_with_once_to_run
    @config.expects(:invoke_command).with("hostname", :foo => "bar", :once => true, :eof => true)
    @config.capture("hostname", :foo => "bar")
  end

  def test_capture_with_sudo_should_avoid_closing_stdin
    @config.expects(:invoke_command).with("sudo hostname", :foo => "bar", :once => true, :eof => false)
    @config.capture("sudo hostname", :foo => "bar")
  end

  def test_capture_with_stderr_should_emit_stderr_via_warn
    ch = mock("channel")
    ch.expects(:[]).with(:server).returns(server("capistrano"))
    @config.expects(:invoke_command).yields(ch, :err, "boom")
    @config.expects(:warn).with("[err :: capistrano] boom")
    @config.capture("hostname")
  end

  def test_capture_with_stdout_should_aggregate_and_return_stdout
    config_expects_invoke_command_to_loop_with(mock("channel"), "foo", "bar", "baz")
    assert_equal "foobarbaz", @config.capture("hostname")
  end

  private

    def config_expects_invoke_command_to_loop_with(channel, *output)
      class <<@config
        attr_accessor :script, :channel
        def invoke_command(*args)
          script.each { |item| yield channel, :out, item }
        end
      end
      @config.channel = channel
      @config.script = output
    end
end
