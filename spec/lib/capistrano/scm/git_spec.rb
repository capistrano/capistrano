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

    describe "#set_defaults" do
      it "makes git_wrapper_path using a random hex value" do
        env.set(:tmp_dir, "/tmp")
        subject.set_defaults
        expect(env.fetch(:git_wrapper_path)).to match(%r{/tmp/git-ssh-\h{20}\.sh})
      end

      it "makes git_max_concurrent_connections" do
        subject.set_defaults
        expect(env.fetch(:git_max_concurrent_connections)).to eq(10)
        env.set(:git_max_concurrent_connections, 7)
        expect(env.fetch(:git_max_concurrent_connections)).to eq(7)
      end

      it "makes git_wait_interval" do
        subject.set_defaults
        expect(env.fetch(:git_wait_interval)).to eq(0)
        env.set(:git_wait_interval, 5)
        expect(env.fetch(:git_wait_interval)).to eq(5)
      end
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
        backend.expects(:execute).with(:git, :'ls-remote', "url", "HEAD").returns(true)

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

      context "with username and password specified" do
        before do
          env.set(:git_http_username, "hello")
          env.set(:git_http_password, "topsecret")
          env.set(:repo_url, "https://example.com/repo.git")
          env.set(:repo_path, "path")
        end

        it "should include the credentials in the url" do
          backend.expects(:execute).with(:git, :clone, "--mirror", "https://hello:topsecret@example.com/repo.git", "path")
          subject.clone_repo
        end
      end
    end

    describe "#update_mirror" do
      it "should run git update" do
        env.set(:repo_url, "url")

        backend.expects(:execute).with(:git, :remote, "set-url", "origin", "url")
        backend.expects(:execute).with(:git, :remote, :update, "--prune")

        subject.update_mirror
      end

      it "should run git update in shallow mode" do
        env.set(:git_shallow_clone, "1")
        env.set(:branch, "branch")
        env.set(:repo_url, "url")

        backend.expects(:execute).with(:git, :remote, "set-url", "origin", "url")
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

    describe "#fetch_revision" do
      it "should capture git rev-list" do
        env.set(:branch, "branch")
        backend.expects(:capture).with(:git, "rev-list --max-count=1 branch").returns("81cec13b777ff46348693d327fc8e7832f79bf43")
        revision = subject.fetch_revision
        expect(revision).to eq("81cec13b777ff46348693d327fc8e7832f79bf43")
      end
    end

    describe "#verify_commit" do
      it "should run git verify-commit" do
        env.set(:branch, "branch")

        backend.expects(:capture).with(:git, "rev-list --max-count=1 branch").returns("81cec13b777ff46348693d327fc8e7832f79bf43")
        backend.expects(:execute).with(:git, :"verify-commit", "81cec13b777ff46348693d327fc8e7832f79bf43")

        subject.verify_commit
      end
    end
  end
end
