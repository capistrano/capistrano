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

    describe 'roles' do
      context 'adding a role' do
        subject { config.role(:app, %w{server1 server2}) }

        before do
          Configuration::Servers.expects(:new).returns(servers)
          servers.expects(:add_role).with(:app, %w{server1 server2})
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

      context 'block is passed to fetch' do
        subject { config.fetch(:key, :default) { fail 'we need this!' } }

        it 'returns the block value' do
          expect { subject }.to raise_error
        end
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
  end

end
