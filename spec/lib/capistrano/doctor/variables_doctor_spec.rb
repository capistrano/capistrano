require "spec_helper"
require "capistrano/doctor/variables_doctor"

module Capistrano
  module Doctor
    describe VariablesDoctor do
      include Capistrano::DSL

      let(:doc) { VariablesDoctor.new }

      before do
        set :branch, "master"
        set :pty, false

        env.variables.untrusted! do
          set :application, "my_app"
          set :repo_tree, "public"
          set :repo_url, ".git"
          set :copy_strategy, :scp
          set :custom_setting, "hello"
          set "string_setting", "hello"
          ask :secret
        end

        fetch :custom_setting
      end

      after { Capistrano::Configuration.reset! }

      it "prints using 4-space indentation" do
        expect { doc.call }.to output(/^ {4}/).to_stdout
      end

      it "prints variable names and values" do
        expect { doc.call }.to output(/:branch\s+"master"$/).to_stdout
        expect { doc.call }.to output(/:pty\s+false$/).to_stdout
        expect { doc.call }.to output(/:application\s+"my_app"$/).to_stdout
        expect { doc.call }.to output(/:repo_url\s+".git"$/).to_stdout
        expect { doc.call }.to output(/:repo_tree\s+"public"$/).to_stdout
        expect { doc.call }.to output(/:copy_strategy\s+:scp$/).to_stdout
        expect { doc.call }.to output(/:custom_setting\s+"hello"$/).to_stdout
        expect { doc.call }.to output(/"string_setting"\s+"hello"$/).to_stdout
      end

      it "prints unanswered question variable as <ask>" do
        expect { doc.call }.to output(/:secret\s+<ask>$/).to_stdout
      end

      it "prints warning for unrecognized variable" do
        expect { doc.call }.to \
          output(/:copy_strategy is not a recognized Capistrano setting/)\
          .to_stdout
      end

      it "does not print warning for unrecognized variable that is fetched" do
        expect { doc.call }.not_to \
          output(/:custom_setting is not a recognized Capistrano setting/)\
          .to_stdout
      end

      it "does not print warning for whitelisted variable" do
        expect { doc.call }.not_to \
          output(/:repo_tree is not a recognized Capistrano setting/)\
          .to_stdout
      end

      describe "Rake" do
        before do
          load File.expand_path("../../../../../lib/capistrano/doctor.rb",
                                __FILE__)
        end

        after do
          Rake::Task.clear
        end

        it "has an doctor:variables task that calls VariablesDoctor" do
          VariablesDoctor.any_instance.expects(:call)
          Rake::Task["doctor:variables"].invoke
        end

        it "has a doctor task that depends on doctor:variables" do
          expect(Rake::Task["doctor"].prerequisites).to \
            include("doctor:variables")
        end
      end
    end
  end
end
