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
        subject.expects(:authentication).returns("")
        context.expects(:repo_url).returns(:url)
        context.expects(:test).with(:svn, :info, :url, "").returns(true)

        subject.check
      end
    end

    describe "#clone" do
      it "should run svn checkout" do
        subject.expects(:authentication).returns("")
        context.expects(:repo_url).returns(:url)
        context.expects(:repo_path).returns(:path)
 
        context.expects(:execute).with(:svn, :checkout, :url, :path, "")

        subject.clone
      end
    end

    describe "#update" do
      it "should run svn update" do
        subject.expects(:authentication).returns("")
        context.expects(:execute).with(:svn, :update, "")

        subject.update
      end
    end

    describe "#release" do
      it "should run svn export" do
        subject.expects(:authentication).returns("")
        context.expects(:release_path).returns(:path)
        
        context.expects(:execute).with(:svn, :export, '.', :path, "")

        subject.release
      end
    end

    describe "#authentication" do
      before do
        subject.stubs(:fetch).with(:svn_username).returns("username")
        subject.stubs(:fetch).with(:svn_password).returns("password")
      end

      it "should skip if no username" do
        subject.stubs(:fetch).with(:svn_username).returns(nil)

        expect(subject.send(:authentication)).to eq("")
      end

      it "should skip if no password" do
        subject.stubs(:fetch).with(:svn_password).returns(nil)

        expect(subject.send(:authentication)).to eq("")
      end

      it "should build the authentication options" do
        expect(subject.send(:authentication)).to eq('--username "username" --password "password" --no-auth-cache')
      end
    end
  end
end
