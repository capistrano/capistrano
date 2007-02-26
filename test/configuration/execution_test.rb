$:.unshift File.dirname(__FILE__) + "/../../lib"

require 'test/unit'
require 'mocha'
require 'capistrano/configuration/execution'
require 'capistrano/task_definition'

class ConfigurationNamespacesDSLTest < Test::Unit::TestCase
  class MockConfig
    include Mocha::AutoVerify

    attr_reader :tasks, :namespaces, :fully_qualified_name, :parent
    attr_reader :state
    attr_accessor :logger

    def initialize(options={})
      @tasks = {}
      @namespaces = {}
      @state = {}
      @fully_qualified_name = options[:fqn]
      @parent = options[:parent]
      @logger = stub(:debug => nil, :info => nil, :important => nil)
    end

    include Capistrano::Configuration::Execution
  end

  def setup
    @config = MockConfig.new
  end

  def test_initialize_should_initialize_collections
    assert_nil @config.rollback_requests
    assert @config.task_call_frames.empty?
  end

  def test_execute_task_with_unknown_task_should_raise_error
    assert_raises(NoMethodError) do
      @config.execute_task(:bogus, @config)
    end
  end

  def test_execute_task_with_unknown_task_and_fail_silently_should_fail_silently
    assert_nothing_raised do
      @config.execute_task(:bogus, @config, true)
    end
  end

  def test_execute_task_should_populate_call_stack
    new_task @config, :testing
    assert_nothing_raised { @config.execute_task :testing, @config }
    assert_equal %w(testing), @config.state[:testing][:stack]
    assert_nil @config.state[:testing][:history]
    assert @config.task_call_frames.empty?
  end

  def test_nested_execute_task_should_add_to_call_stack
    new_task @config, :testing
    new_task(@config, :outer) { execute_task :testing, self }

    assert_nothing_raised { @config.execute_task :outer, @config }
    assert_equal %w(outer testing), @config.state[:testing][:stack]
    assert_nil @config.state[:testing][:history]
    assert @config.task_call_frames.empty?
  end

  def test_execute_task_should_execute_before_hook_if_defined
    new_task @config, :testing
    new_task @config, :before_testing
    @config.execute_task :testing, @config
    assert_equal %w(before_testing testing), @config.state[:trail]
  end

  def test_execute_task_should_execute_after_hook_if_defined
    new_task @config, :testing
    new_task @config, :after_testing
    @config.execute_task :testing, @config
    assert_equal %w(testing after_testing), @config.state[:trail]
  end

  def test_transaction_outside_of_task_should_raise_exception
    assert_raises(ScriptError) { @config.transaction {} }
  end

  def test_transaction_without_block_should_raise_argument_error
    new_task(@config, :testing) { transaction }
    assert_raises(ArgumentError) { @config.execute_task :testing, @config }
  end

  def test_transaction_should_initialize_transaction_history
    @config.state[:inspector] = stack_inspector
    new_task(@config, :testing) { transaction { instance_eval(&state[:inspector]) } }
    @config.execute_task :testing, @config
    assert_equal [], @config.state[:testing][:history]
  end

  def test_transaction_from_within_transaction_should_not_start_new_transaction
    new_task(@config, :third, &stack_inspector)
    new_task(@config, :second) { transaction { execute_task(:third, self) } }
    new_task(@config, :first) { transaction { execute_task(:second, self) } }
    # kind of fragile...not sure how else to check that transaction was only
    # really run twice...but if the transaction was REALLY run, logger.info
    # will be called once when it starts, and once when it finishes.
    @config.logger = mock()
    @config.logger.stubs(:debug)
    @config.logger.expects(:info).times(2)
    @config.execute_task :first, @config
  end

  def test_exception_raised_in_transaction_should_call_all_registered_rollback_handlers_in_reverse_order
    new_task(@config, :aaa) { on_rollback { (state[:rollback] ||= []) << :aaa } }
    new_task(@config, :bbb) { on_rollback { (state[:rollback] ||= []) << :bbb } }
    new_task(@config, :ccc) {}
    new_task(@config, :ddd) { on_rollback { (state[:rollback] ||= []) << :ddd }; execute_task(:bbb, self); execute_task(:ccc, self) }
    new_task(@config, :eee) { transaction { execute_task(:ddd, self); execute_task(:aaa, self); raise "boom" } }
    assert_raises(RuntimeError) do
      @config.execute_task :eee, @config
    end
    assert_equal [:aaa, :bbb, :ddd], @config.state[:rollback]
    assert_nil @config.rollback_requests
    assert @config.task_call_frames.empty?
  end

  def test_exception_during_rollback_should_simply_be_logged_and_ignored
    new_task(@config, :aaa) { on_rollback { state[:aaa] = true; raise LoadError, "ouch" }; execute_task(:bbb, self) }
    new_task(@config, :bbb) { raise MadError, "boom" }
    new_task(@config, :ccc) { transaction { execute_task(:aaa, self) } }
    assert_raises(NameError) do
      @config.execute_task :ccc, @config
    end
    assert @config.state[:aaa]
  end

  private

    def stack_inspector
      Proc.new do
        (state[:trail] ||= []) << current_task.fully_qualified_name
        data = state[current_task.name] = {}
        data[:stack] = task_call_frames.map { |frame| frame.task.fully_qualified_name }
        data[:history] = rollback_requests && rollback_requests.map { |frame| frame.task.fully_qualified_name }
      end
    end

    def new_task(namespace, name, options={}, &block)
      block ||= stack_inspector
      namespace.tasks[name] = Capistrano::TaskDefinition.new(name, namespace, &block)
    end
end