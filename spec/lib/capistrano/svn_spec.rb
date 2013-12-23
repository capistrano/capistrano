require 'spec_helper'

require 'capistrano/svn'

module Capistrano
  describe Svn do
    let(:context) { Class.new.new }
    subject { Capistrano::Svn.new(context, Capistrano::Svn::DefaultStrategy) }

    describe "#svn" do
      it "should call execute svn in the context, with arguments" do
        context.expects(:execute).with(:svn, :init)
        subject.svn(:init)
      end
    end
  end

  describe Svn::DefaultStrategy do
    let(:context) { Class.new.new }
    subject { Capistrano::Svn.new(context, Capistrano::Svn::DefaultStrategy) }

    describe "#test" do
      it "should call test for repo HEAD" do  
        context.expects(:repo_path).returns("/path/to/repo")
        context.expects(:test).with " [ -d /path/to/repo/.svn ] "

        subject.test
      end
    end

    describe "#check" do
      it "should test the repo url" do
        context.expects(:repo_url).returns(:url)
        context.expects(:test).with(:svn, :info, :url).returns(true)

        subject.check
      end
    end

    describe "#clone" do
      it "should run svn checkout" do
        context.expects(:repo_url).returns(:url)
        context.expects(:repo_path).returns(:path)
 
        context.expects(:execute).with(:svn, :checkout, :url, :path)

        subject.clone
      end
    end

    describe "#update" do
      it "should run svn update" do
        context.expects(:execute).with(:svn, :update)

        subject.update
      end
    end

    describe "#release" do
      it "should run svn export" do        
        context.expects(:release_path).returns(:path)
        
        context.expects(:execute).with(:svn, :export, '.', :path)

        subject.release
      end
    end
  end
end
