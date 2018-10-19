require "spec_helper"
require "capistrano/doctor/environment_doctor"

module Capistrano
  module Doctor
    describe EnvironmentDoctor do
      let(:doc) { EnvironmentDoctor.new }

      it "prints using 4-space indentation" do
        expect { doc.call }.to output(/^ {4}/).to_stdout
      end

      it "prints the Ruby version" do
        expect { doc.call }.to\
          output(/#{Regexp.quote(RUBY_DESCRIPTION)}/).to_stdout
      end

      it "prints the Rubygems version" do
        expect { doc.call }.to output(/#{Regexp.quote(Gem::VERSION)}/).to_stdout
      end

      describe "Rake" do
        before do
          load File.expand_path("../../../../../lib/capistrano/doctor.rb",
                                __FILE__)
        end

        after do
          Rake::Task.clear
        end

        it "has an doctor:environment task that calls EnvironmentDoctor", capture_io: true do
          EnvironmentDoctor.any_instance.expects(:call)
          Rake::Task["doctor:environment"].invoke
        end

        it "has a doctor task that depends on doctor:environment" do
          expect(Rake::Task["doctor"].prerequisites).to \
            include("doctor:environment")
        end
      end
    end
  end
end
