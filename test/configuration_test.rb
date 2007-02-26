$:.unshift File.dirname(__FILE__) + "/../lib"

require 'test/unit'
require 'capistrano/configuration'

class ConfigurationTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
  end

  def test_task_without_options
    block = Proc.new { }
    @config.task :hello, &block
    assert_equal 1, @config.actor.tasks.length
    assert_equal :hello, @config.actor.tasks[0][0]
    assert_equal({}, @config.actor.tasks[0][1])
    assert_equal block, @config.actor.tasks[0][2]
  end

  def test_task_with_options
    block = Proc.new { }
    @config.task :hello, :roles => :app, &block
    assert_equal 1, @config.actor.tasks.length
    assert_equal :hello, @config.actor.tasks[0][0]
    assert_equal({:roles => :app}, @config.actor.tasks[0][1])
    assert_equal block, @config.actor.tasks[0][2]
  end

  def test_task_description
    block = Proc.new { }
    @config.desc "A sample task"
    @config.task :hello, &block
    assert_equal "A sample task", @config.actor.tasks[0][1][:desc]
  end
end
