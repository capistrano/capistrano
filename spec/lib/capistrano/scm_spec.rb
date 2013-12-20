require 'spec_helper'

require 'capistrano/scm'

module RaiseNotImplementedMacro
  def raise_not_implemented_on(method)
    it "should raise NotImplemented on #{method}" do
      expect {
        subject.send(method)
      }.to raise_error(NotImplementedError)
    end
  end
end

RSpec.configure do
  include RaiseNotImplementedMacro
end

module DummyStrategy
  def test
    test!("you dummy!")
  end
end

module BlindStrategy; end

module Capistrano
  describe SCM do
    let(:context) { Class.new.new }

    describe "#initialize" do
      subject { Capistrano::SCM.new(context, DummyStrategy) }

      it "should load the provided strategy" do
        context.expects(:test).with("you dummy!")
        subject.test
      end
    end

    describe "Convenience methods" do
      subject { Capistrano::SCM.new(context, BlindStrategy) }

      describe "#test!" do
        it "should return call test on the context" do
          context.expects(:test).with(:x)
          subject.test!(:x)
        end
      end

      describe "#repo_url" do
        it "should return the repo url according to the context" do
          context.expects(:repo_url).returns(:url)
          subject.repo_url.should == :url
        end
      end

      describe "#repo_path" do
        it "should return the repo path according to the context" do
          context.expects(:repo_path).returns(:path)
          subject.repo_path.should == :path
        end
      end

      describe "#release_path" do
        it "should return the release path according to the context" do
          context.expects(:release_path).returns('/path/to/nowhere')
          subject.release_path.should == '/path/to/nowhere'
        end
      end

      describe "#fetch" do
        it "should call fetch on the context" do
          context.expects(:fetch)
          subject.fetch(:branch)
        end
      end
    end

    describe "With a 'blind' strategy" do
      subject { Capistrano::SCM.new(context, BlindStrategy) }

      describe "#test" do
        raise_not_implemented_on(:test)
      end

      describe "#check" do
        raise_not_implemented_on(:check)
      end

      describe "#clone" do
        raise_not_implemented_on(:clone)
      end

      describe "#update" do
        raise_not_implemented_on(:update)
      end

      describe "#release" do
        raise_not_implemented_on(:release)
      end
    end
  end
end

