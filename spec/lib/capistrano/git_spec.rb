require "spec_helper"

require "capistrano/git"

module Capistrano
  describe Git do
    let(:context) { Class.new.new }
    subject { Capistrano::Git.new(context, Capistrano::Git::DefaultStrategy) }

    describe "#git" do
      it "should call execute git in the context, with arguments" do
        context.expects(:execute).with(:git, :init)
        subject.git(:init)
      end
    end
  end

  describe Git::DefaultStrategy do
    let(:context) { Class.new.new }
    subject { Capistrano::Git.new(context, Capistrano::Git::DefaultStrategy) }

    describe "#test" do
      it "should call test for repo HEAD" do
        context.expects(:repo_path).returns("/path/to/repo")
        context.expects(:test).with " [ -f /path/to/repo/HEAD ] "

        subject.test
      end
    end

    describe "#check" do
      it "should test the repo url" do
        context.expects(:repo_url).returns(:url)
        context.expects(:execute).with(:git, :'ls-remote --heads', :url).returns(true)

        subject.check
      end
    end

    describe "#clone" do
      it "should run git clone" do
        context.expects(:fetch).with(:git_shallow_clone).returns(nil)
        context.expects(:repo_url).returns(:url)
        context.expects(:repo_path).returns(:path)
        context.expects(:execute).with(:git, :clone, "--mirror", :url, :path)

        subject.clone
      end

      it "should run git clone in shallow mode" do
        context.expects(:fetch).with(:git_shallow_clone).returns("1")
        context.expects(:repo_url).returns(:url)
        context.expects(:repo_path).returns(:path)

        context.expects(:execute).with(:git, :clone, "--mirror", "--depth", "1", "--no-single-branch", :url, :path)

        subject.clone
      end
    end

    describe "#update" do
      it "should run git update" do
        context.expects(:fetch).with(:git_shallow_clone).returns(nil)
        context.expects(:execute).with(:git, :remote, :update, "--prune")

        subject.update
      end

      it "should run git update in shallow mode" do
        context.expects(:fetch).with(:git_shallow_clone).returns("1")
        context.expects(:fetch).with(:branch).returns(:branch)
        context.expects(:execute).with(:git, :fetch, "--depth", "1", "origin", :branch)

        subject.update
      end
    end

    describe "#release" do
      it "should run git archive without a subtree" do
        context.expects(:fetch).with(:repo_tree).returns(nil)
        context.expects(:fetch).with(:branch).returns(:branch)
        context.expects(:release_path).returns(:path)

        context.expects(:execute).with(:git, :archive, :branch, "| tar -x -f - -C", :path)

        subject.release
      end

      it "should run git archive with a subtree" do
        context.expects(:fetch).with(:repo_tree).returns("tree")
        context.expects(:fetch).with(:branch).returns(:branch)
        context.expects(:release_path).returns(:path)

        context.expects(:execute).with(:git, :archive, :branch, "tree", "| tar -x --strip-components 1 -f - -C", :path)

        subject.release
      end
    end

    describe "#fetch_revision" do
      it "should capture git rev-list" do
        context.expects(:fetch).with(:branch).returns(:branch)
        context.expects(:capture).with(:git, "rev-list --max-count=1 branch").returns("81cec13b777ff46348693d327fc8e7832f79bf43")
        revision = subject.fetch_revision
        expect(revision).to eq("81cec13b777ff46348693d327fc8e7832f79bf43")
      end
    end
  end
end
