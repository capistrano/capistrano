require "spec_helper"

require "capistrano/scm/svn"

module Capistrano
  describe SCM::Svn do
    subject { Capistrano::SCM::Svn.new }

    # This allows us to easily use `set`, `fetch`, etc. in the examples.
    let(:env) { Capistrano::Configuration.env }

    # Stub the SSHKit backend so we can set up expectations without the plugin
    # actually executing any commands.
    let(:backend) { stub }
    before { SSHKit::Backend.stubs(:current).returns(backend) }

    # Mimic the deploy flow tasks so that the plugin can register its hooks.
    before do
      Rake::Task.define_task("deploy:new_release_path")
      Rake::Task.define_task("deploy:check")
      Rake::Task.define_task("deploy:set_current_revision")
    end

    # Clean up any tasks or variables that the plugin defined.
    after do
      Rake::Task.clear
      Capistrano::Configuration.reset!
    end

    describe "#svn" do
      it "should call execute svn in the context, with arguments" do
        env.set(:svn_username, "someuser")
        env.set(:svn_password, "somepassword")
        backend.expects(:execute).with(:svn, :init, "--username someuser", "--password somepassword")
        subject.svn(:init)
      end
    end

    describe "#repo_mirror_exists?" do
      it "should call test for repo HEAD" do
        env.set(:repo_path, "/path/to/repo")
        backend.expects(:test).with " [ -d /path/to/repo/.svn ] "

        subject.repo_mirror_exists?
      end
    end

    describe "#check_repo_is_reachable" do
      it "should test the repo url" do
        env.set(:repo_url, :url)
        env.set(:svn_username, "someuser")
        env.set(:svn_password, "somepassword")
        backend.expects(:test).with(:svn, :info, :url, "--username someuser", "--password somepassword").returns(true)

        subject.check_repo_is_reachable
      end
    end

    describe "#clone_repo" do
      it "should run svn checkout" do
        env.set(:repo_url, :url)
        env.set(:repo_path, "path")
        env.set(:svn_username, "someuser")
        env.set(:svn_password, "somepassword")

        backend.expects(:execute).with(:svn, :checkout, :url, "path", "--username someuser", "--password somepassword")

        subject.clone_repo
      end
    end

    describe "#update_mirror" do
      it "should run svn update" do
        env.set(:repo_url, "url")
        env.set(:repo_path, "path")
        backend.expects(:capture).with(:svn, :info, "path").returns("URL: url\n")

        env.set(:svn_username, "someuser")
        env.set(:svn_password, "somepassword")
        backend.expects(:execute).with(:svn, :update, "--username someuser", "--password somepassword")

        subject.update_mirror
      end

      context "for specific revision" do
        it "should run svn update" do
          env.set(:repo_url, "url")
          env.set(:repo_path, "path")
          backend.expects(:capture).with(:svn, :info, "path").returns("URL: url\n")

          env.set(:svn_username, "someuser")
          env.set(:svn_password, "somepassword")
          env.set(:svn_revision, "12345")
          backend.expects(:execute).with(:svn, :update, "--username someuser", "--password somepassword", "--revision 12345")

          subject.update_mirror
        end
      end

      it "should run svn switch if repo_url is changed" do
        env.set(:repo_url, "url")
        env.set(:repo_path, "path")
        backend.expects(:capture).with(:svn, :info, "path").returns("URL: old_url\n")

        env.set(:svn_username, "someuser")
        env.set(:svn_password, "somepassword")
        backend.expects(:execute).with(:svn, :switch, "url", "--username someuser", "--password somepassword")
        backend.expects(:execute).with(:svn, :update, "--username someuser", "--password somepassword")

        subject.update_mirror
      end
    end

    describe "#archive_to_release_path" do
      it "should run svn export" do
        env.set(:release_path, "path")
        env.set(:svn_username, "someuser")
        env.set(:svn_password, "somepassword")

        backend.expects(:execute).with(:svn, :export, "--force", ".", "path", "--username someuser", "--password somepassword")

        subject.archive_to_release_path
      end
    end

    describe "#fetch_revision" do
      it "should capture svn version" do
        env.set(:repo_path, "path")

        backend.expects(:capture).with(:svnversion, "path").returns("12345")

        revision = subject.fetch_revision
        expect(revision).to eq("12345")
      end
    end
  end
end
