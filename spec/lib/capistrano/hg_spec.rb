require "spec_helper"

require "capistrano/hg"

module Capistrano
  describe Hg do
    let(:context) { Class.new.new }
    subject { Capistrano::Hg.new(context, Capistrano::Hg::DefaultStrategy) }

    describe "#hg" do
      it "should call execute hg in the context, with arguments" do
        context.expects(:execute).with(:hg, :init)
        subject.hg(:init)
      end
    end
  end

  describe Hg::DefaultStrategy do
    let(:context) { Class.new.new }
    subject { Capistrano::Hg.new(context, Capistrano::Hg::DefaultStrategy) }

    describe "#test" do
      it "should call test for repo HEAD" do
        context.expects(:repo_path).returns("/path/to/repo")
        context.expects(:test).with " [ -d /path/to/repo/.hg ] "

        subject.test
      end
    end

    describe "#check" do
      it "should test the repo url" do
        context.expects(:repo_url).returns(:url)
        context.expects(:execute).with(:hg, "id", :url)

        subject.check
      end
    end

    describe "#clone" do
      it "should run hg clone" do
        context.expects(:repo_url).returns(:url)
        context.expects(:repo_path).returns(:path)

        context.expects(:execute).with(:hg, "clone", "--noupdate", :url, :path)

        subject.clone
      end
    end

    describe "#update" do
      it "should run hg update" do
        context.expects(:execute).with(:hg, "pull")

        subject.update
      end
    end

    describe "#release" do
      it "should run hg archive without a subtree" do
        context.expects(:fetch).with(:repo_tree).returns(nil)
        context.expects(:fetch).with(:branch).returns(:branch)
        context.expects(:release_path).returns(:path)

        context.expects(:execute).with(:hg, "archive", :path, "--rev", :branch)

        subject.release
      end

      it "should run hg archive with a subtree" do
        context.expects(:fetch).with(:repo_tree).returns("tree")
        context.expects(:fetch).with(:branch).returns(:branch)
        context.expects(:release_path).returns(:path)

        context.expects(:execute).with(:hg, "archive --type tgz -p . -I", "tree", "--rev", :branch, "| tar -x --strip-components 1 -f - -C", :path)

        subject.release
      end
    end

    describe "#fetch_revision" do
      it "should capture hg log" do
        context.expects(:fetch).with(:branch).returns(:branch)
        context.expects(:capture).with(:hg, "log --rev branch --template \"{node}\n\"").returns("01abcde")
        revision = subject.fetch_revision
        expect(revision).to eq("01abcde")
      end
    end
  end
end
