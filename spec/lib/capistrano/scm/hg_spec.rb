require "spec_helper"

require "capistrano/scm/hg"

module Capistrano
  describe SCM::Hg do
    subject { Capistrano::SCM::Hg.new }

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

    describe "#hg" do
      it "should call execute hg in the context, with arguments" do
        backend.expects(:execute).with(:hg, :init)
        subject.hg(:init)
      end
    end

    describe "#repo_mirror_exists?" do
      it "should call test for repo HEAD" do
        env.set(:repo_path, "/path/to/repo")
        backend.expects(:test).with " [ -d /path/to/repo/.hg ] "

        subject.repo_mirror_exists?
      end
    end

    describe "#check_repo_is_reachable" do
      it "should test the repo url" do
        env.set(:repo_url, :url)
        backend.expects(:execute).with(:hg, "id", :url)

        subject.check_repo_is_reachable
      end
    end

    describe "#clone_repo" do
      it "should run hg clone" do
        env.set(:repo_url, :url)
        env.set(:repo_path, "path")

        backend.expects(:execute).with(:hg, "clone", "--noupdate", :url, "path")

        subject.clone_repo
      end
    end

    describe "#update_mirror" do
      it "should run hg update" do
        backend.expects(:execute).with(:hg, "pull")

        subject.update_mirror
      end
    end

    describe "#archive_to_release_path" do
      it "should run hg archive without a subtree" do
        env.set(:branch, :branch)
        env.set(:release_path, "path")

        backend.expects(:execute).with(:hg, "archive", "path", "--rev", :branch)

        subject.archive_to_release_path
      end

      it "should run hg archive with a subtree" do
        env.set(:repo_tree, "tree")
        env.set(:branch, :branch)
        env.set(:release_path, "path")
        env.set(:tmp_dir, "/tmp")

        SecureRandom.stubs(:hex).with(10).returns("random")
        backend.expects(:execute).with(:hg, "archive -p . -I", "tree", "--rev", :branch, "/tmp/random.tar")
        backend.expects(:execute).with(:mkdir, "-p", "path")
        backend.expects(:execute).with(:tar, "-x --strip-components 1 -f", "/tmp/random.tar", "-C", "path")
        backend.expects(:execute).with(:rm, "/tmp/random.tar")

        subject.archive_to_release_path
      end
    end

    describe "#fetch_revision" do
      it "should capture hg log" do
        env.set(:branch, :branch)
        backend.expects(:capture).with(:hg, "log --rev branch --template \"{node}\n\"").returns("01abcde")
        revision = subject.fetch_revision
        expect(revision).to eq("01abcde")
      end
    end
  end
end
