require 'utils'
require 'capistrano/configuration/alias_task'
require 'capistrano/configuration/execution'
require 'capistrano/configuration/namespaces'
require 'capistrano/task_definition'

class AliasTaskTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :options
    attr_accessor :logger

    def initialize(options={})
      @options = {}
      @logger = options.delete(:logger)
    end

    include Capistrano::Configuration::AliasTask
    include Capistrano::Configuration::Execution
    include Capistrano::Configuration::Namespaces
  end

  def setup
    @config = MockConfig.new( :logger => stub(:debug => nil, :info => nil, :important => nil) )
  end

  def test_makes_a_copy_of_the_task
    @config.task(:foo) { 42 }
    @config.alias_task 'new_foo', 'foo'

    assert @config.tasks.key?(:new_foo)
  end

  def test_original_task_remain_with_same_name
    @config.task(:foo) { 42 }
    @config.alias_task 'new_foo', 'foo'

    assert_equal :foo, @config.tasks[:foo].name
    assert_equal :new_foo, @config.tasks[:new_foo].name
  end

  def test_aliased_task_do_the_same
    @config.task(:foo) { 42 }
    @config.alias_task 'new_foo', 'foo'

    assert_equal 42, @config.find_and_execute_task('new_foo')
  end

  def test_aliased_task_should_preserve_description
    @config.task(:foo, :desc => "the Ultimate Question of Life, the Universe, and Everything" ) { 42 }
    @config.alias_task 'new_foo', 'foo'

    task = @config.find_task('foo')
    new_task = @config.find_task('new_foo')

    assert_equal task.description, new_task.description
  end

  def test_aliased_task_should_preserve_on_error
    @config.task(:foo, :on_error => :continue) { 42 }
    @config.alias_task 'new_foo', 'foo'

    task = @config.find_task('foo')
    new_task = @config.find_task('new_foo')

    assert_equal task.on_error, new_task.on_error
  end

  def test_aliased_task_should_preserve_max_hosts
    @config.task(:foo, :max_hosts => 5) { 42 }
    @config.alias_task 'new_foo', 'foo'

    task = @config.find_task('foo')
    new_task = @config.find_task('new_foo')

    assert_equal task.max_hosts, new_task.max_hosts
  end

  def test_raise_exception_when_task_doesnt_exist
    assert_raises(Capistrano::NoSuchTaskError) { @config.alias_task 'non_existant_task', 'fail_miserably' }
  end

  def test_convert_task_names_using_to_str
    @config.task(:foo, :role => :app) { 42 }

    @config.alias_task 'one', 'foo'
    @config.alias_task :two, 'foo'
    @config.alias_task 'three', :foo
    @config.alias_task :four, :foo

    assert @config.tasks.key?(:one)
    assert @config.tasks.key?(:two)
    assert @config.tasks.key?(:three)
    assert @config.tasks.key?(:four)
  end

  def test_raise_an_exception_when_task_names_can_not_be_converted
    @config.task(:foo, :role => :app) { 42 }

    assert_raises(ArgumentError) { @config.alias_task mock('x'), :foo }
  end

  def test_should_include_namespace
    @config.namespace(:outer) do
      task(:foo) { 42 }
      alias_task 'new_foo', 'foo'

      namespace(:inner) do
        task(:foo) { 43 }
        alias_task 'new_foo', 'foo'
      end
    end

    assert_equal 42, @config.find_and_execute_task('outer:new_foo')
    assert_equal 42, @config.find_and_execute_task('outer:foo')
    assert_equal 43, @config.find_and_execute_task('outer:inner:new_foo')
    assert_equal 43, @config.find_and_execute_task('outer:inner:foo')
  end
end
