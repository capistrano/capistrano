require "#{File.dirname(__FILE__)}/utils"
require 'capistrano/task_definition'

class TaskDefinitionTest < Test::Unit::TestCase
  def setup
    @namespace = namespace do |s|
      role(s, :app, "app1", :primary => true)
      role(s, :app, "app2", "app3")
      role(s, :web, "web1", "web2")
      role(s, :report, "app2", :no_deploy => true)
      role(s, :file, "file", :no_deploy => true)
    end
  end

  def test_task_without_roles_should_apply_to_all_defined_hosts
    task = new_task(:testing)
    assert_equal %w(app1 app2 app3 web1 web2 file).sort, task.servers.map { |s| s.host }.sort
  end

  def test_task_with_explicit_role_list_should_apply_only_to_those_roles
    task = new_task(:testing, @namespace, :roles => %w(app web))
    assert_equal %w(app1 app2 app3 web1 web2).sort, task.servers.map { |s| s.host }.sort
  end

  def test_task_with_single_role_should_apply_only_to_that_role
    task = new_task(:testing, @namespace, :roles => :web)
    assert_equal %w(web1 web2).sort, task.servers.map { |s| s.host }.sort
  end

  def test_task_with_hosts_option_should_apply_only_to_those_hosts
    task = new_task(:testing, @namespace, :hosts => %w(foo bar))
    assert_equal %w(foo bar).sort, task.servers.map { |s| s.host }.sort
  end

  def test_task_with_single_hosts_option_should_apply_only_to_that_host
    task = new_task(:testing, @namespace, :hosts => "foo")
    assert_equal %w(foo).sort, task.servers.map { |s| s.host }.sort
  end

  def test_task_with_roles_as_environment_variable_should_apply_only_to_that_role
    ENV['ROLES'] = "app,file"
    task = new_task(:testing)
    assert_equal %w(app1 app2 app3 file).sort, task.servers.map { |s| s.host }.sort
  ensure
    ENV['ROLES'] = nil
  end

  def test_task_with_hosts_as_environment_variable_should_apply_only_to_those_hosts
    ENV['HOSTS'] = "foo,bar"
    task = new_task(:testing)
    assert_equal %w(foo bar).sort, task.servers.map { |s| s.host }.sort
  ensure
    ENV['HOSTS'] = nil
  end

  def test_task_with_only_should_apply_only_to_matching_tasks
    task = new_task(:testing, @namespace, :roles => :app, :only => { :primary => true })
    assert_equal %w(app1), task.servers.map { |s| s.host }
  end

  def test_task_with_except_should_apply_only_to_matching_tasks
    task = new_task(:testing, @namespace, :except => { :no_deploy => true })
    assert_equal %w(app1 app2 app3 web1 web2).sort, task.servers.map { |s| s.host }.sort
  end

  def test_fqn_at_top_level_should_be_task_name
    task = new_task(:testing)
    assert_equal "testing", task.fully_qualified_name
  end

  def test_fqn_in_namespace_should_include_namespace_fqn
    ns = namespace("outer:inner")
    task = new_task(:testing, ns)
    assert_equal "outer:inner:testing", task.fully_qualified_name
  end

  def test_fqn_at_top_level_when_default_should_be_default
    task = new_task(:default)
    assert_equal "default", task.fully_qualified_name
  end

  def test_fqn_in_namespace_when_default_should_be_namespace_fqn
    ns = namespace("outer:inner")
    task = new_task(:default, ns)
    ns.stubs(:default_task => task)
    assert_equal "outer:inner", task.fully_qualified_name
  end

  def test_task_should_require_block
    assert_raises(ArgumentError) do
      Capistrano::TaskDefinition.new(:testing, @namespace)
    end
  end

  def test_description_should_return_empty_string_if_not_given
    assert_equal "", new_task(:testing).description
  end

  def test_description_should_return_desc_attribute
    assert_equal "something", new_task(:testing, @namespace, :desc => "something").description
  end

  def test_description_should_strip_leading_and_trailing_whitespace
    assert_equal "something", new_task(:testing, @namespace, :desc => "   something   ").description
  end

  def test_description_should_normalize_newlines
    assert_equal "a\nb\nc", new_task(:testing, @namespace, :desc => "a\nb\r\nc").description
  end

  def test_task_brief_description_should_return_first_sentence_in_description
    desc = "This is the task. It does all kinds of things."
    task = new_task(:testing, @namespace, :desc => desc)
    assert_equal "This is the task.", task.brief_description
  end

  def test_task_brief_description_should_truncate_if_length_given
    desc = "This is the task that does all kinds of things. And then some."
    task = new_task(:testing, @namespace, :desc => desc)
    assert_equal "This is the task ...", task.brief_description(20)
  end

  private

    def namespace(fqn=nil)
      space = stub(:roles => {}, :fully_qualified_name => fqn, :default_task => nil)
      yield(space) if block_given?
      space
    end

    def role(space, name, *args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      space.roles[name] ||= []
      space.roles[name].concat(args.map { |h| Capistrano::ServerDefinition.new(h, opts) })
    end

    def new_task(name, namespace=@namespace, options={}, &block)
      block ||= Proc.new {}
      task = Capistrano::TaskDefinition.new(name, namespace, options, &block)
      assert_equal block, task.body
      return task
    end
end