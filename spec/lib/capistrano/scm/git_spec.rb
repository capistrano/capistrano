require "spec_helper"

require "capistrano/scm/git"

module Capistrano
  describe SCM::Git do
    subject { Capistrano::SCM::Git.new }

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

    describe "#git" do
      it "should call execute git in the context, with arguments" do
        backend.expects(:execute).with(:git, :init)
        subject.git(:init)
      end
    end

    describe "#repo_mirror_exists?" do
      it "should call test for repo HEAD" do
        env.set(:repo_path, "/path/to/repo")
        backend.expects(:test).with " [ -f /path/to/repo/HEAD ] "

        subject.repo_mirror_exists?
      end
    end

    describe "#check_repo_is_reachable" do
      it "should test the repo url" do
        env.set(:repo_url, "url")
        backend.expects(:execute).with(:git, :'ls-remote --heads', "url").returns(true)

        subject.check_repo_is_reachable
      end
    end

    describe "#clone_repo" do
      it "should run git clone" do
        env.set(:repo_url, "url")
        env.set(:repo_path, "path")
        backend.expects(:execute).with(:git, :clone, "--mirror", "url", "path")

        subject.clone_repo
      end

      it "should run git clone in shallow mode" do
        env.set(:git_shallow_clone, "1")
        env.set(:repo_url, "url")
        env.set(:repo_path, "path")

        backend.expects(:execute).with(:git, :clone, "--mirror", "--depth", "1", "--no-single-branch", "url", "path")

        subject.clone_repo
      end
    end

    describe "#update_mirror" do
      it "should run git update" do
        backend.expects(:execute).with(:git, :remote, :update, "--prune")

        subject.update_mirror
      end

      it "should run git update in shallow mode" do
        env.set(:git_shallow_clone, "1")
        env.set(:branch, "branch")
        backend.expects(:execute).with(:git, :fetch, "--depth", "1", "origin", "branch")

        subject.update_mirror
      end
    end

    describe "#archive_to_release_path" do
      it "should run git archive without a subtree" do
        env.set(:branch, "branch")
        env.set(:release_path, "path")

        backend.expects(:execute).with(:git, :archive, "branch", "| /usr/bin/env tar -x -f - -C", "path")

        subject.archive_to_release_path
      end

      it "should run git archive with a subtree" do
        env.set(:repo_tree, "tree")
        env.set(:branch, "branch")
        env.set(:release_path, "path")

        backend.expects(:execute).with(:git, :archive, "branch", "tree", "| /usr/bin/env tar -x --strip-components 1 -f - -C", "path")

        subject.archive_to_release_path
      end

      it "should run tar with an overridden name" do
        env.set(:branch, "branch")
        env.set(:release_path, "path")
        SSHKit.config.command_map.expects(:[]).with(:tar).returns("/usr/bin/env gtar")

        backend.expects(:execute).with(:git, :archive, "branch", "| /usr/bin/env gtar -x -f - -C", "path")

        subject.archive_to_release_path
      end
    end

    describe "#submodules_to_release_path" do
      before do
        env.set(:branch, "branch")
        env.set(:repo_path, Pathname.new("/repo"))
        env.set(:release_timestamp, 20_161_221_135_840)
        env.set(:release_path, Pathname.new("/releases/20161221135840"))
      end

      it "should switch to relative release director" do
        backend.expects(:within).with("../releases/20161221135840")

        subject.submodules_to_release_path
      end

      it "should set git environment variables" do
        backend.stubs(:within).yields
        backend.expects(:with).with(
          "GIT_DIR" => "/repo",
          "GIT_WORK_TREE" => "/releases/20161221135840",
          "GIT_INDEX_FILE" => "/releases/20161221135840/INDEX_20161221135840"
        )

        subject.submodules_to_release_path
      end

      it "should run git commands and remove temp file" do
        backend.stubs(:within).yields
        backend.expects(:with).yields

        backend.expects(:execute).with(:git, :reset, "--mixed", "branch")
        backend.expects(:execute).with(:git, :submodule, "update", "--init", "--depth", 1, "--checkout", "--recursive")
        backend.expects(:execute).with(:rm, "/releases/20161221135840/INDEX_20161221135840")

        subject.submodules_to_release_path
      end
    end

    describe "#fetch_revision" do
      it "should capture git rev-list" do
        env.set(:branch, "branch")
        backend.expects(:capture).with(:git, "rev-list --max-count=1 branch").returns("81cec13b777ff46348693d327fc8e7832f79bf43")
        revision = subject.fetch_revision
        expect(revision).to eq("81cec13b777ff46348693d327fc8e7832f79bf43")
      end
    end
  end
end
