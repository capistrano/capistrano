require 'spec_helper'
require 'capistrano/plugin'

module Capistrano
  describe Plugin do
    include Rake::DSL
    include Capistrano::DSL

    class DummyPlugin < Capistrano::Plugin
      def define_tasks
        task :hello do
        end
      end

      def register_hooks
        before 'deploy:published', 'hello'
      end
    end

    class ExternalTasksPlugin < Capistrano::Plugin
      def define_tasks
        eval_rakefile(
          File.expand_path('../../../support/tasks/plugin.rake', __FILE__)
        )
      end

      # Called from plugin.rake to demonstrate that helper methods work
      def hello
        set :plugin_result, 'hello'
      end
    end

    before do
      # Define an example task to allow testing hooks
      task 'deploy:published'
    end

    after do
      # Clean up any tasks or variables we created during the tests
      Rake::Task.clear
      Capistrano::Configuration.reset!
    end

    it 'defines tasks when constructed' do
      DummyPlugin.new
      expect(Rake::Task['hello']).not_to be_nil
    end

    it 'registers hooks when constructed' do
      DummyPlugin.new
      expect(Rake::Task['deploy:published'].prerequisites).to include('hello')
    end

    it 'skips registering hooks if :hooks => false' do
      DummyPlugin.new(hooks: false)
      expect(Rake::Task['deploy:published'].prerequisites).to be_empty
    end

    it "doesn't call set_defaults immediately" do
      dummy = DummyPlugin.new
      dummy.expects(:set_defaults).never
    end

    it 'calls set_defaults during load:defaults' do
      dummy = DummyPlugin.new
      dummy.expects(:set_defaults).once
      Rake::Task['load:defaults'].invoke
    end

    it 'is able to load tasks from a .rake file' do
      ExternalTasksPlugin.new
      Rake::Task['plugin_test'].invoke
      expect(fetch(:plugin_result)).to eq('hello')
    end

    it 'exposes the SSHKit backend to subclasses' do
      SSHKit::Backend.expects(:current).returns(:backend)
      plugin = DummyPlugin.new
      expect(plugin.send(:backend)).to eq(:backend)
    end
  end
end
