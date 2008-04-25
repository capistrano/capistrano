require "utils"
require 'capistrano/task_definition'
require 'capistrano/configuration/servers'

class ConfigurationServersTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :roles

    def initialize
      @roles = {}
    end

    include Capistrano::Configuration::Servers
  end

  def setup
    @config = MockConfig.new
    role(@config, :app, "app1", :primary => true)
    role(@config, :app, "app2", "app3")
    role(@config, :web, "web1", "web2")
    role(@config, :report, "app2", :no_deploy => true)
    role(@config, :file, "file", :no_deploy => true)
  end

  def test_task_without_roles_should_apply_to_all_defined_hosts
    task = new_task(:testing)
    assert_equal %w(app1 app2 app3 web1 web2 file).sort, @config.find_servers_for_task(task).map { |s| s.host }.sort
  end

  def test_task_with_explicit_role_list_should_apply_only_to_those_roles
    task = new_task(:testing, @config, :roles => %w(app web))
    assert_equal %w(app1 app2 app3 web1 web2).sort, @config.find_servers_for_task(task).map { |s| s.host }.sort
  end

  def test_task_with_single_role_should_apply_only_to_that_role
    task = new_task(:testing, @config, :roles => :web)
    assert_equal %w(web1 web2).sort, @config.find_servers_for_task(task).map { |s| s.host }.sort
  end

  def test_task_with_hosts_option_should_apply_only_to_those_hosts
    task = new_task(:testing, @config, :hosts => %w(foo bar))
    assert_equal %w(foo bar).sort, @config.find_servers_for_task(task).map { |s| s.host }.sort
  end

  def test_task_with_single_hosts_option_should_apply_only_to_that_host
    task = new_task(:testing, @config, :hosts => "foo")
    assert_equal %w(foo).sort, @config.find_servers_for_task(task).map { |s| s.host }.sort
  end

  def test_task_with_roles_as_environment_variable_should_apply_only_to_that_role
    ENV['ROLES'] = "app,file"
    task = new_task(:testing)
    assert_equal %w(app1 app2 app3 file).sort, @config.find_servers_for_task(task).map { |s| s.host }.sort
  ensure
    ENV['ROLES'] = nil
  end

  def test_task_with_hosts_as_environment_variable_should_apply_only_to_those_hosts
    ENV['HOSTS'] = "foo,bar"
    task = new_task(:testing)
    assert_equal %w(foo bar).sort, @config.find_servers_for_task(task).map { |s| s.host }.sort
  ensure
    ENV['HOSTS'] = nil
  end

  def test_task_with_only_should_apply_only_to_matching_tasks
    task = new_task(:testing, @config, :roles => :app, :only => { :primary => true })
    assert_equal %w(app1), @config.find_servers_for_task(task).map { |s| s.host }
  end

  def test_task_with_except_should_apply_only_to_matching_tasks
    task = new_task(:testing, @config, :except => { :no_deploy => true })
    assert_equal %w(app1 app2 app3 web1 web2).sort, @config.find_servers_for_task(task).map { |s| s.host }.sort
  end

  def test_options_to_find_servers_for_task_should_override_options_in_task
    task = new_task(:testing, @config, :roles => :web)
    assert_equal %w(app1 app2 app3).sort, @config.find_servers_for_task(task, :roles => :app).map { |s| s.host }.sort
  end

  def test_find_servers_with_lambda_for_hosts_should_be_evaluated
    assert_equal %w(foo), @config.find_servers(:hosts => lambda { "foo" }).map { |s| s.host }.sort
    assert_equal %w(bar foo), @config.find_servers(:hosts => lambda { %w(foo bar) }).map { |s| s.host }.sort
  end

  def test_find_servers_with_lambda_for_roles_should_be_evaluated
    assert_equal %w(app1 app2 app3), @config.find_servers(:roles => lambda { :app }).map { |s| s.host }.sort
    assert_equal %w(app2 file), @config.find_servers(:roles => lambda { [:report, :file] }).map { |s| s.host }.sort
  end
end