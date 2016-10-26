require "spec_helper"
require "capistrano/plugin"
require "capistrano/scm/plugin"

module Capistrano
  class Configuration
    class ExamplePlugin < Capistrano::Plugin
      def set_defaults
        set_if_empty :example_variable, "foo"
      end

      def define_tasks
        task :example
        task :example_prerequisite
      end

      def register_hooks
        before :example, :example_prerequisite
      end
    end

    class ExampleSCMPlugin < Capistrano::SCM::Plugin
    end

    describe PluginInstaller do
      include Capistrano::DSL

      let(:installer) { PluginInstaller.new }
      let(:options) { {} }
      let(:plugin) { ExamplePlugin.new }

      before do
        installer.install(plugin, **options)
      end

      after do
        Rake::Task.clear
        Capistrano::Configuration.reset!
      end

      context "installing plugin" do
        it "defines tasks" do
          expect(Rake::Task[:example]).to_not be_nil
          expect(Rake::Task[:example_prerequisite]).to_not be_nil
        end

        it "registers hooks" do
          task = Rake::Task[:example]
          expect(task.prerequisites).to eq([:example_prerequisite])
        end

        it "sets defaults when load:defaults is invoked" do
          expect(fetch(:example_variable)).to be_nil
          invoke "load:defaults"
          expect(fetch(:example_variable)).to eq("foo")
        end

        it "doesn't say an SCM is installed" do
          expect(installer.scm_installed?).to be_falsey
        end
      end

      context "installing plugin class" do
        let(:plugin) { ExamplePlugin }

        it "defines tasks" do
          expect(Rake::Task[:example]).to_not be_nil
          expect(Rake::Task[:example_prerequisite]).to_not be_nil
        end
      end

      context "installing plugin without hooks" do
        let(:options) { { load_hooks: false } }

        it "doesn't register hooks" do
          task = Rake::Task[:example]
          expect(task.prerequisites).to be_empty
        end
      end

      context "installing plugin and loading immediately" do
        let(:options) { { load_immediately: true } }

        it "sets defaults immediately" do
          expect(fetch(:example_variable)).to eq("foo")
        end
      end

      context "installing an SCM plugin" do
        let(:plugin) { ExampleSCMPlugin }

        it "says an SCM is installed" do
          expect(installer.scm_installed?).to be_truthy
        end
      end
    end
  end
end
