require "#{File.dirname(__FILE__)}/../../utils"
require 'capistrano/configuration/actions/invocation'

class ConfigurationActionsInvocationTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :options

    def initialize
      @options = {}
    end

    def [](*args)
      @options[*args]
    end

    def fetch(*args)
      @options.fetch(*args)
    end

    include Capistrano::Configuration::Actions::Invocation
  end

  def setup
    @config = MockConfig.new
    @original_io_proc = MockConfig.default_io_proc
    @config.stubs(:logger).returns(stub_everything)
  end

  def teardown
    MockConfig.default_io_proc = @original_io_proc
  end

  def test_run_options_should_be_passed_to_execute_on_servers
    @config.expects(:execute_on_servers).with(:foo => "bar")
    @config.run "ls", :foo => "bar"
  end

  def test_run_without_block_should_use_default_io_proc
    @config.expects(:execute_on_servers).yields(%w(s1 s2 s3).map { |s| mock(:host => s) })
    @config.expects(:sessions).returns(Hash.new { |h,k| h[k] = k.host.to_sym }).times(3)
    prepare_command("ls", [:s1, :s2, :s3], {:logger => @config.logger})
    MockConfig.default_io_proc = inspectable_proc
    @config.run "ls"
  end

  def test_run_with_block_should_use_block
    @config.expects(:execute_on_servers).yields(%w(s1 s2 s3).map { |s| mock(:host => s) })
    @config.expects(:sessions).returns(Hash.new { |h,k| h[k] = k.host.to_sym }).times(3)
    prepare_command("ls", [:s1, :s2, :s3], {:logger => @config.logger})
    MockConfig.default_io_proc = Proc.new { |a,b,c| raise "shouldn't get here" }
    @config.run("ls", &inspectable_proc)
  end

  def test_default_io_proc_should_log_stdout_arguments_as_info
    ch = { :host => "capistrano",
           :options => { :logger => mock("logger") } }
    ch[:options][:logger].expects(:info).with("data stuff", "out :: capistrano")
    MockConfig.default_io_proc[ch, :out, "data stuff"]
  end

  def test_default_io_proc_should_log_stderr_arguments_as_important
    ch = { :host => "capistrano",
           :options => { :logger => mock("logger") } }
    ch[:options][:logger].expects(:important).with("data stuff", "err :: capistrano")
    MockConfig.default_io_proc[ch, :err, "data stuff"]
  end

  def test_sudo_should_default_to_sudo
    @config.expects(:run).with("sudo ls", {})
    @config.sudo "ls"
  end

  def test_sudo_should_use_sudo_variable_definition
    @config.expects(:run).with("/opt/local/bin/sudo ls", {})
    @config.options[:sudo] = "/opt/local/bin/sudo"
    @config.sudo "ls"
  end

  def test_sudo_should_interpret_as_option_as_user
    @config.expects(:run).with("sudo -u app ls", {})
    @config.sudo "ls", :as => "app"
  end

  def test_sudo_should_pass_options_through_to_run
    @config.expects(:run).with("sudo ls", :foo => "bar")
    @config.sudo "ls", :foo => "bar"
  end

  def test_sudo_behavior_callback_should_send_password_when_prompted
    ch = mock("channel")
    ch.expects(:send_data).with("g00b3r\n")
    @config.options[:password] = "g00b3r"
    @config.sudo_behavior_callback(nil)[ch, nil, "Password: "]
  end

  def test_sudo_behavior_callback_should_send_password_when_prompted_with_SuSE_dialect
    ch = mock("channel")
    ch.expects(:send_data).with("g00b3r\n")
    @config.options[:password] = "g00b3r"
    @config.sudo_behavior_callback(nil)[ch, nil, "user's password: "]
  end

  def test_sudo_behavior_callback_with_incorrect_password_on_first_prompt
    ch = mock("channel")
    ch.stubs(:[]).with(:host).returns("capistrano")
    @config.expects(:reset!).with(:password)
    @config.sudo_behavior_callback(nil)[ch, nil, "blah blah try again blah blah"]
  end

  def test_sudo_behavior_callback_with_incorrect_password_on_subsequent_prompts
    callback = @config.sudo_behavior_callback(nil)

    ch = mock("channel")
    ch.stubs(:[]).with(:host).returns("capistrano")
    ch2 = mock("channel")
    ch2.stubs(:[]).with(:host).returns("cap2")

    @config.expects(:reset!).with(:password).times(2)

    callback[ch, nil, "blah blah try again blah blah"]
    callback[ch2, nil, "blah blah try again blah blah"] # shouldn't call reset!
    callback[ch, nil, "blah blah try again blah blah"]
  end

  def test_sudo_behavior_callback_should_defer_to_fallback_for_other_output
    callback = @config.sudo_behavior_callback(inspectable_proc)

    a = mock("channel", :called => true)
    b = mock("stream", :called => true)
    c = mock("data", :called => true)

    callback[a, b, c]
  end

  def test_invoke_command_should_default_to_run
    @config.expects(:run).with("ls", :once => true)
    @config.invoke_command("ls", :once => true)
  end

  def test_invoke_command_should_delegate_to_method_identified_by_via
    @config.expects(:foobar).with("ls", :once => true)
    @config.invoke_command("ls", :once => true, :via => :foobar)
  end

  private

    def inspectable_proc
      Proc.new do |ch, stream, data|
        ch.called
        stream.called
        data.called
      end
    end

    def prepare_command(command, sessions, options)
      a = mock("channel", :called => true)
      b = mock("stream", :called => true)
      c = mock("data", :called => true)
      Capistrano::Command.expects(:process).with(command, sessions, options).yields(a, b, c)
    end
end