require 'spec_helper'

module Capistrano
  describe Configuration do
    let(:config) { Configuration.new }
    let(:servers) { stub }

    describe '.env' do
      it 'is a global accessor to a single instance' do
        Configuration.env.set(:test, true)
        expect(Configuration.env.fetch(:test)).to be_true
      end
    end

    describe '.reset!' do
      it 'blows away the existing `env` and creates a new one' do
        old_env = Configuration.env
        Configuration.reset!
        expect(Configuration.env).not_to be old_env
      end
    end

    describe 'roles' do
      context 'adding a role' do
        subject { config.role(:app, %w{server1 server2}) }

        before do
          Configuration::Servers.expects(:new).returns(servers)
          servers.expects(:add_role).with(:app, %w{server1 server2}, {})
        end

        it 'adds the role' do
          expect(subject)
        end
      end
    end

    describe 'setting and fetching' do
      subject { config.fetch(:key, :default) }

      context 'value is set' do
        before do
          config.set(:key, :value)
        end

        it 'returns the set value' do
          expect(subject).to eq :value
        end
      end

      context 'value is not set' do
        it 'returns the default value' do
          expect(subject).to eq :default
        end
      end

      context 'value is a proc' do
        subject { config.fetch(:key, Proc.new { :proc } ) }
        it 'calls the proc' do
          expect(subject).to eq :proc
        end
      end

      context 'value is a lambda' do
        subject { config.fetch(:key, lambda { :lambda } ) }
        it 'calls the lambda' do
          expect(subject).to eq :lambda
        end
      end

      context 'value inside proc inside a proc' do
        subject { config.fetch(:key, Proc.new { Proc.new { "some value" } } ) }
        it 'calls all procs and lambdas' do
          expect(subject).to eq "some value"
        end
      end

      context 'value inside lambda inside a lambda' do
        subject { config.fetch(:key, lambda { lambda { "some value" } } ) }
        it 'calls all procs and lambdas' do
          expect(subject).to eq "some value"
        end
      end

      context 'value inside lambda inside a proc' do
        subject { config.fetch(:key, Proc.new { lambda { "some value" } } ) }
        it 'calls all procs and lambdas' do
          expect(subject).to eq "some value"
        end
      end

      context 'value inside proc inside a lambda' do
        subject { config.fetch(:key, lambda { Proc.new { "some value" } } ) }
        it 'calls all procs and lambdas' do
          expect(subject).to eq "some value"
        end
      end

      context 'lambda with parameters' do
        subject { config.fetch(:key, lambda { |c| c }).call(42) }
        it 'is returned as a lambda' do
          expect(subject).to eq 42
        end
      end

      context 'block is passed to fetch' do
        subject { config.fetch(:key, :default) { fail 'we need this!' } }

        it 'returns the block value' do
          expect { subject }.to raise_error
        end
      end
    end

    describe 'keys' do
      subject { config.keys }

      before do
        config.set(:key1, :value1)
        config.set(:key2, :value2)
      end

      it 'returns all set keys' do
        expect(subject).to match_array [:key1, :key2]
      end
    end

    describe 'deleting' do
      before do
        config.set(:key, :value)
      end

      it 'deletes the value' do
        config.delete(:key)
        expect(config.fetch(:key)).to be_nil
      end
    end

    describe 'asking' do
      let(:question) { stub }

      before do
        Configuration::Question.expects(:new).with(config, :branch, :default).
          returns(question)
      end

      it 'prompts for the value when fetching' do
        config.ask(:branch, :default)
        expect(config.fetch(:branch)).to eq question
      end
    end

    describe 'setting the backend' do
      it 'by default, is SSHKit' do
        expect(config.backend).to eq SSHKit
      end

      it 'can be set to another class' do
        config.backend = :test
        expect(config.backend).to eq :test
      end
    end
  end
end
