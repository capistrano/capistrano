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
      it "returns true" do
        expect(subject.test).to be_true
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
      it "returns true" do
        expect(subject.clone).to be_true
      end
    end

    describe "#update" do
      it "returns true" do
        expect(subject.update).to be_true
      end
    end

    describe "#release" do
      it "should run svn export" do
        context.expects(:fetch).returns(:svn_location)
        context.expects(:repo_url).returns(:url)
        context.expects(:release_path).returns(:path)

        context.expects(:execute).with(:svn, :export, "#{:url}/#{:svn_location}", :path)

        subject.release
      end
    end
  end
end
