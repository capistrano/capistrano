require 'spec_helper'

module Capistrano

  class Configuration
    describe Roles do
      let(:roles) { Roles.new }

      describe 'adding a role' do
        subject { roles.add_role(:app, %w{server1 server2}) }

        before do
          Server.expects(:new).with('server1')
          Server.expects(:new).with('server2')
        end

        it 'adds the role, and creates new server instances' do
          expect{subject}.to change{roles.count}.from(0).to(1)
        end
      end

      describe 'fetching servers' do
        let(:server1) { stub }
        let(:server2) { stub }
        let(:server3) { stub }

        before do
          Server.stubs(:new).with('server1').returns(server1)
          Server.stubs(:new).with('server2').returns(server2)
          Server.stubs(:new).with('server3').returns(server3)

          roles.add_role(:app, %w{server1 server2})
          roles.add_role(:web, %w{server2 server3})
        end

        it 'returns the correct app servers' do
          expect(roles.fetch_roles([:app])).to eq [server1, server2]
        end

        it 'returns the correct web servers' do
          expect(roles.fetch_roles([:web])).to eq [server2, server3]
        end

        it 'returns the correct app and web servers' do
          expect(roles.fetch_roles([:app, :web])).to eq [server1, server2, server3]
        end

        it 'returns all servers' do
          expect(roles.all).to eq [server1, server2, server3]
        end
      end
    end
  end

  describe Configuration do
    let(:config) { Configuration.new }
    let(:roles) { stub }

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
          Configuration::Roles.expects(:new).returns(roles)
          roles.expects(:add_role).with(:app, %w{server1 server2})
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

  describe Configuration::Question do
    let(:question) { Configuration::Question.new(env, key, default) }
    let(:default) { :default }
    let(:key) { :branch }
    let(:env) { stub }

    describe '.new' do
      it 'takes a key, default' do
        question
      end
    end

    describe '#call' do
      subject { question.call }

      context 'value is entered' do
        let(:branch) { 'branch' }

        before do
          $stdout.expects(:puts).with('Please enter branch: |default|')
          $stdin.expects(:gets).returns(branch)
        end

        it 'sets the value' do
          env.expects(:set).with(key, branch)
          question.call
        end
      end

      context 'value is not entered' do
        let(:branch) { default }

        before do
          $stdout.expects(:puts).with('Please enter branch: |default|')
          $stdin.expects(:gets).returns('')
        end

        it 'sets the default as the value' do
          env.expects(:set).with(key, branch)
          question.call
        end
      end
    end
  end
end
