require 'spec_helper'

module Capistrano
  class Configuration

    describe Question do

      let(:question) { Question.new(env, key, default, options) }
      let(:question_without_echo) { Question.new(env, key, default, echo: false) }
      let(:default) { :default }
      let(:key) { :branch }
      let(:env) { stub }
      let(:options) { nil }

      describe '.new' do
        it 'takes a key, default, options' do
          question
        end
      end

      describe '#call' do
        context 'value is entered' do
          let(:branch) { 'branch' }

          before do
            $stdout.expects(:print).with('Please enter branch (default): ')
          end

          it 'sets the echoed value' do
            $stdin.expects(:gets).returns(branch)
            $stdin.expects(:noecho).never
            env.expects(:set).with(key, branch)

            question.call
          end

          it 'sets the value but does not echo it' do
            $stdin.expects(:noecho).returns(branch)
            $stdout.expects(:print).with("\n")
            env.expects(:set).with(key, branch)

            question_without_echo.call
          end
        end

        context 'value is not entered' do
          let(:branch) { default }

          before do
            $stdout.expects(:print).with('Please enter branch (default): ')
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
