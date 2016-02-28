require "spec_helper"

require "capistrano/svn"

module Capistrano
  describe Svn do
    let(:context) { Class.new.new }
    subject { Capistrano::Svn.new(context, Capistrano::Svn::DefaultStrategy) }

    describe "#svn" do
      it "should call execute svn in the context, with arguments" do
        context.expects(:execute).with(:svn, :init, "--username someuser", "--password somepassword")
        context.expects(:fetch).twice.with(:svn_username).returns("someuser")
        context.expects(:fetch).twice.with(:svn_password).returns("somepassword")
        context.expects(:fetch).once.with(:svn_revision).returns(nil)
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
        context.expects(:test).with(:svn, :info, :url, "--username someuser", "--password somepassword").returns(true)
        context.expects(:fetch).twice.with(:svn_username).returns("someuser")
        context.expects(:fetch).twice.with(:svn_password).returns("somepassword")

        subject.check
      end
    end

    describe "#clone" do
      it "should run svn checkout" do
        context.expects(:repo_url).returns(:url)
        context.expects(:repo_path).returns(:path)
        context.expects(:fetch).twice.with(:svn_username).returns("someuser")
        context.expects(:fetch).twice.with(:svn_password).returns("somepassword")
        context.expects(:fetch).once.with(:svn_revision).returns(nil)

        context.expects(:execute).with(:svn, :checkout, :url, :path, "--username someuser", "--password somepassword")

        subject.clone
      end
    end

    describe "#update" do
      it "should run svn update" do
        context.expects(:execute).with(:svn, :update, "--username someuser", "--password somepassword")
        context.expects(:fetch).twice.with(:svn_username).returns("someuser")
        context.expects(:fetch).twice.with(:svn_password).returns("somepassword")
        context.expects(:fetch).once.with(:svn_revision).returns(nil)

        subject.update
      end
    end

    describe "#update_specific_revision" do
      it "should run svn update and update to a specific revision" do
        context.expects(:execute).with(:svn, :update, "--username someuser", "--password somepassword", "--revision 12345")
        context.expects(:fetch).twice.with(:svn_username).returns("someuser")
        context.expects(:fetch).twice.with(:svn_password).returns("somepassword")
        context.expects(:fetch).twice.with(:svn_revision).returns("12345")

        subject.update
      end
    end

    describe "#release" do
      it "should run svn export" do
        context.expects(:release_path).returns(:path)
        context.expects(:fetch).twice.with(:svn_username).returns("someuser")
        context.expects(:fetch).twice.with(:svn_password).returns("somepassword")
        context.expects(:fetch).once.with(:svn_revision).returns(nil)

        context.expects(:execute).with(:svn, :export, "--force", ".", :path, "--username someuser", "--password somepassword")

        subject.release
      end
    end

    describe "#fetch_revision" do
      it "should capture svn version" do
        context.expects(:repo_path).returns(:path)

        context.expects(:capture).with(:svnversion, :path).returns("12345")

        revision = subject.fetch_revision
        expect(revision).to eq("12345")
      end
    end
  end
end
