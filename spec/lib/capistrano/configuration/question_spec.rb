require 'spec_helper'

module Capistrano
  class Configuration

    describe Question do

      let(:question) { Question.new(env, key, default) }
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
end
