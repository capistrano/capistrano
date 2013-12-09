require 'spec_helper'

require 'capistrano/git'

module Capistrano
  describe Git do
    let(:context) { Class.new.new }

    describe "#test" do
      it "should call test for repo HEAD" do
        context.expects(:repo_path).returns("/path/to/repo")
        context.expects(:test).with " [ -f /path/to/repo/HEAD ] "

        Capistrano::Git.test(context)
      end
    end

    describe "#check" do
      it "should test the repo url" do
        context.expects(:repo_url).returns(:url)
        context.expects(:test).with(:git, :'ls-remote', :url).returns(true)

        Capistrano::Git.check(context)
      end
    end

    describe "#clone" do
      it "should run git clone" do
        context.expects(:repo_url).returns(:url)
        context.expects(:repo_path).returns(:path)

        context.expects(:execute).with(:git, :clone, '--mirror', :url, :path)

        Capistrano::Git.clone(context)
      end
    end

    describe "#update" do
      it "should run git update" do
        context.expects(:execute).with(:git, :remote, :update)

        Capistrano::Git.update(context)
      end
    end

    describe "#release" do
      it "should run git archive" do
        context.expects(:fetch).returns(:branch)
        context.expects(:release_path).returns(:path)

        context.expects(:execute).with(:git, :archive, :branch, '| tar -x -C', :path)

        Capistrano::Git.release(context)
      end
    end
  end
end
