require 'spec_helper'

require 'capistrano/git'

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
        context.expects(:test).with(:git, :'ls-remote', :url).returns(true)

        subject.check
      end
    end

    describe "#clone" do
      it "should run git clone" do
        context.expects(:repo_url).returns(:url)
        context.expects(:repo_path).returns(:path)

        context.expects(:execute).with(:git, :clone, '--mirror', :url, :path)

        subject.clone
      end
    end

    describe "#update" do
      it "should run git update" do
        context.expects(:execute).with(:git, :remote, :update)

        subject.update
      end
    end

    describe "#release" do
      it "should run git archive" do
        context.expects(:fetch).returns(:branch)
        context.expects(:release_path).returns(:path)

        context.expects(:execute).with(:git, :archive, :branch, '| tar -x -C', :path)

        subject.release
      end
    end
  end
end
