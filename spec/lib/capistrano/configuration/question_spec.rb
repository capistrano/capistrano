require "spec_helper"

module Capistrano
  class Configuration
    describe Question do
      let(:question) { Question.new(key, default, options) }
      let(:question_without_echo) { Question.new(key, default, echo: false) }
      let(:default) { :default }
      let(:key) { :branch }
      let(:options) { nil }

      describe ".new" do
        it "takes a key, default, options" do
          question
        end
      end

      describe "#call" do
        context "value is entered" do
          let(:branch) { "branch" }

          before do
            $stdout.expects(:print).with("Please enter branch (default): ")
          end

          it "returns the echoed value" do
            $stdin.expects(:gets).returns(branch)
            $stdin.expects(:noecho).never

            expect(question.call).to eq(branch)
          end

          it "returns the value but does not echo it" do
            $stdin.expects(:noecho).returns(branch)
            $stdout.expects(:print).with("\n")

            expect(question_without_echo.call).to eq(branch)
          end
        end

        context "value is not entered" do
          let(:branch) { default }

          before do
            $stdout.expects(:print).with("Please enter branch (default): ")
            $stdin.expects(:gets).returns("")
          end

          it "returns the default as the value" do
            expect(question.call).to eq(branch)
          end
        end
      end
    end
  end
end
