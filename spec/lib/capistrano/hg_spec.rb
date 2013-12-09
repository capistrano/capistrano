require 'spec_helper'

require 'capistrano/hg'

module Capistrano
  describe Hg do
    let(:context) { Class.new.new }

    describe "#test" do
      it "should call test for repo HEAD" do
        context.expects(:repo_path).returns("/path/to/repo")
        context.expects(:test).with " [ -d /path/to/repo/.hg ] "

        Capistrano::Hg.test(context)
      end
    end

    describe "#check" do
      it "should test the repo url" do
        context.expects(:repo_url).returns(:url)
        context.expects(:execute).with("hg", "id", :url)

        Capistrano::Hg.check(context)
      end
    end

    describe "#clone" do
      it "should run hg clone" do
        context.expects(:repo_url).returns(:url)
        context.expects(:repo_path).returns(:path)

        context.expects(:execute).with("hg", "clone", '--noupdate', :url, :path)

        Capistrano::Hg.clone(context)
      end
    end

    describe "#update" do
      it "should run hg update" do
        context.expects(:execute).with("hg", "pull")

        Capistrano::Hg.update(context)
      end
    end

    describe "#release" do
      it "should run hg archive" do
        context.expects(:fetch).returns(:branch)
        context.expects(:release_path).returns(:path)

        context.expects(:execute).with("hg", "archive", :path, "--rev", :branch)

        Capistrano::Hg.release(context)
      end
    end
  end
end
