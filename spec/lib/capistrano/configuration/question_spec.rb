require 'spec_helper'

module Capistrano
  class Configuration

    describe Question do

      let(:question) { Question.new(env, key, default, options) }
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
        subject { question.call }

        context 'value is entered' do
          let(:branch) { 'branch' }

          before do
            $stdout.expects(:print).with('Please enter branch (default): ')
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
            $stdout.expects(:print).with('Please enter branch (default): ')
            $stdin.expects(:gets).returns('')
          end

          it 'sets the default as the value' do
            env.expects(:set).with(key, branch)
            question.call
          end

        end

        describe 'highline behavior' do
          let(:highline) { stub }

          before do
            question.expects(:highline_ask).yields(highline).returns("answer")
            env.expects(:set).with(key, "answer")
          end

          context 'with no options' do
            let(:options) { nil }

            it 'passes echo: true to HighLine' do
              highline.expects(:"echo=").with(true)
              question.call
            end
          end

          context 'with echo: false' do
            let(:options) { { echo: false } }

            it 'passes echo: false to HighLine' do
              highline.expects(:"echo=").with(false)
              question.call
            end
          end
        end
      end
    end

  end
end
