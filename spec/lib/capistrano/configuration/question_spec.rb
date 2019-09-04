require "spec_helper"

module Capistrano
  class Configuration
    describe Question do
      let(:question) { Question.new(key, default, stdin: stdin) }
      let(:question_without_echo) { Question.new(key, default, echo: false, stdin: stdin) }
      let(:question_without_default) { Question.new(key, nil, stdin: stdin) }
      let(:default) { :default }
      let(:key) { :branch }
      let(:stdin) { stub(tty?: true) }

      describe ".new" do
        it "takes a key, default, options" do
          question
        end
      end

      describe "#call" do
        context "value is entered" do
          let(:branch) { "branch" }

          it "returns the echoed value" do
            $stdout.expects(:print).with("Please enter branch (default): ")
            stdin.expects(:gets).returns(branch)
            stdin.expects(:noecho).never

            expect(question.call).to eq(branch)
          end

          it "returns the value but does not echo it" do
            $stdout.expects(:print).with("Please enter branch (default): ")
            stdin.expects(:noecho).returns(branch)
            $stdout.expects(:print).with("\n")

            expect(question_without_echo.call).to eq(branch)
          end

          it "returns the value but has no default between parenthesis" do
            $stdout.expects(:print).with("Please enter branch: ")
            stdin.expects(:gets).returns(branch)
            stdin.expects(:noecho).never

            expect(question_without_default.call).to eq(branch)
          end
        end

        context "value is not entered" do
          let(:branch) { default }

          before do
            $stdout.expects(:print).with("Please enter branch (default): ")
            stdin.expects(:gets).returns("")
          end

          it "returns the default as the value" do
            expect(question.call).to eq(branch)
          end
        end

        context "tty unavailable", capture_io: true do
          before do
            stdin.expects(:gets).never
            stdin.expects(:tty?).returns(false)
          end

          it "returns the default as the value" do
            expect(question.call).to eq(default)
          end
        end
      end
    end
  end
end
