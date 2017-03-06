require "spec_helper"

module Capistrano
  class Configuration
    describe SCMResolver do
      include Capistrano::DSL

      let(:resolver) { SCMResolver.new }

      before do
        Rake::Task.define_task("deploy:check")
        Rake::Task.define_task("deploy:new_release_path")
        Rake::Task.define_task("deploy:set_current_revision")
        set :scm, SCMResolver::DEFAULT_GIT
      end

      after do
        Rake::Task.clear
        Capistrano::Configuration.reset!
      end

      context "default scm, no plugin installed" do
        it "emits a warning" do
          expect { resolver.resolve }.to output(/will not load the git scm/i).to_stderr
        end

        it "activates the git scm" do
          resolver.resolve
          expect(Rake::Task["git:wrapper"]).not_to be_nil
        end

        it "sets :scm to :git" do
          resolver.resolve
          expect(fetch(:scm)).to eq(:git)
        end
      end

      context "default scm, git plugin installed" do
        before do
          install_plugin Capistrano::SCM::Git
        end

        it "emits no warning" do
          expect { resolver.resolve }.not_to output.to_stderr
        end

        it "deletes :scm" do
          resolver.resolve
          expect(fetch(:scm)).to be_nil
        end
      end
    end
  end
end
