require "utils"
require 'capistrano/configuration/actions/invocation'

class ConfigurationActionsInvocationTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :options
    attr_accessor :debug

    def initialize
      @options = {}
    end

    def [](*args)
      @options[*args]
    end

    def set(name, value)
      @options[name] = value
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
    @config.expects(:execute_on_servers).yields(%w(s1 s2 s3).map { |s| server(s) })
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

  def test_add_default_command_options_should_return_bare_options_if_there_is_no_env_or_shell_specified
    assert_equal({:foo => "bar"}, @config.add_default_command_options(:foo => "bar"))
  end

  def test_add_default_command_options_should_merge_default_environment_as_env
    @config[:default_environment][:bang] = "baz"
    assert_equal({:foo => "bar", :env => { :bang => "baz" }}, @config.add_default_command_options(:foo => "bar"))
  end

  def test_add_default_command_options_should_merge_env_with_default_environment
    @config[:default_environment][:bang] = "baz"
    @config[:default_environment][:bacon] = "crunchy"
    assert_equal({:foo => "bar", :env => { :bang => "baz", :bacon => "chunky", :flip => "flop" }}, @config.add_default_command_options(:foo => "bar", :env => {:bacon => "chunky", :flip => "flop"}))
  end

  def test_add_default_command_options_should_use_default_shell_if_present
    @config.set :default_shell, "/bin/bash"
    assert_equal({:foo => "bar", :shell => "/bin/bash"}, @config.add_default_command_options(:foo => "bar"))
  end

  def test_add_default_command_options_should_use_default_shell_of_false_if_present
    @config.set :default_shell, false
    assert_equal({:foo => "bar", :shell => false}, @config.add_default_command_options(:foo => "bar"))
  end

  def test_add_default_command_options_should_use_shell_in_preference_of_default_shell
    @config.set :default_shell, "/bin/bash"
    assert_equal({:foo => "bar", :shell => "/bin/sh"}, @config.add_default_command_options(:foo => "bar", :shell => "/bin/sh"))
  end

  def test_default_io_proc_should_log_stdout_arguments_as_info
    ch = { :host => "capistrano",
           :server => server("capistrano"),
           :options => { :logger => mock("logger") } }
    ch[:options][:logger].expects(:info).with("data stuff", "out :: capistrano")
    MockConfig.default_io_proc[ch, :out, "data stuff"]
  end

  def test_default_io_proc_should_log_stderr_arguments_as_important
    ch = { :host => "capistrano",
           :server => server("capistrano"),
           :options => { :logger => mock("logger") } }
    ch[:options][:logger].expects(:important).with("data stuff", "err :: capistrano")
    MockConfig.default_io_proc[ch, :err, "data stuff"]
  end

  def test_sudo_should_default_to_sudo
    @config.expects(:run).with("sudo -p 'sudo password: ' ls", {})
    @config.sudo "ls"
  end

  def test_sudo_should_use_sudo_variable_definition
    @config.expects(:run).with("/opt/local/bin/sudo -p 'sudo password: ' ls", {})
    @config.options[:sudo] = "/opt/local/bin/sudo"
    @config.sudo "ls"
  end

  def test_sudo_should_interpret_as_option_as_user
    @config.expects(:run).with("sudo -p 'sudo password: ' -u app ls", {})
    @config.sudo "ls", :as => "app"
  end

  def test_sudo_should_pass_options_through_to_run
    @config.expects(:run).with("sudo -p 'sudo password: ' ls", :foo => "bar")
    @config.sudo "ls", :foo => "bar"
  end

  def test_sudo_should_interpret_sudo_prompt_variable_as_custom_prompt
    @config.set :sudo_prompt, "give it to me: "
    @config.expects(:run).with("sudo -p 'give it to me: ' ls", {})
    @config.sudo "ls"
  end

  def test_sudo_behavior_callback_should_send_password_when_prompted_with_default_sudo_prompt
    ch = mock("channel")
    ch.expects(:send_data).with("g00b3r\n")
    @config.options[:password] = "g00b3r"
    @config.sudo_behavior_callback(nil)[ch, nil, "sudo password: "]
  end

  def test_sudo_behavior_callback_should_send_password_when_prompted_with_custom_sudo_prompt
    ch = mock("channel")
    ch.expects(:send_data).with("g00b3r\n")
    @config.set :sudo_prompt, "give it to me: "
    @config.options[:password] = "g00b3r"
    @config.sudo_behavior_callback(nil)[ch, nil, "give it to me: "]
  end

  def test_sudo_behavior_callback_with_incorrect_password_on_first_prompt
    ch = mock("channel")
    ch.stubs(:[]).with(:host).returns("capistrano")
    ch.stubs(:[]).with(:server).returns(server("capistrano"))
    @config.expects(:reset!).with(:password)
    @config.sudo_behavior_callback(nil)[ch, nil, "Sorry, try again."]
  end

  def test_sudo_behavior_callback_with_incorrect_password_on_subsequent_prompts
    callback = @config.sudo_behavior_callback(nil)

    ch = mock("channel")
    ch.stubs(:[]).with(:host).returns("capistrano")
    ch.stubs(:[]).with(:server).returns(server("capistrano"))
    ch2 = mock("channel")
    ch2.stubs(:[]).with(:host).returns("cap2")
    ch2.stubs(:[]).with(:server).returns(server("cap2"))

    @config.expects(:reset!).with(:password).times(2)

    callback[ch, nil, "Sorry, try again."]
    callback[ch2, nil, "Sorry, try again."] # shouldn't call reset!
    callback[ch, nil, "Sorry, try again."]
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
