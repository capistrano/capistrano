require "spec_helper"
require "capistrano/doctor/gems_doctor"
require "airbrussh/version"
require "sshkit/version"
require "net/ssh/version"

module Capistrano
  module Doctor
    describe GemsDoctor do
      let(:doc) { GemsDoctor.new }

      it "prints using 4-space indentation" do
        expect { doc.call }.to output(/^ {4}/).to_stdout
      end

      it "prints the Capistrano version" do
        expect { doc.call }.to\
          output(/capistrano\s+#{Regexp.quote(Capistrano::VERSION)}/).to_stdout
      end

      it "prints the Rake version" do
        expect { doc.call }.to\
          output(/rake\s+#{Regexp.quote(Rake::VERSION)}/).to_stdout
      end

      it "prints the SSHKit version" do
        expect { doc.call }.to\
          output(/sshkit\s+#{Regexp.quote(SSHKit::VERSION)}/).to_stdout
      end

      it "prints the Airbrussh version" do
        expect { doc.call }.to\
          output(/airbrussh\s+#{Regexp.quote(Airbrussh::VERSION)}/).to_stdout
      end

      it "prints the net-ssh version" do
        expect { doc.call }.to\
          output(/net-ssh\s+#{Regexp.quote(Net::SSH::Version::STRING)}/).to_stdout
      end

      it "warns that new version is available" do
        Gem.stubs(:latest_version_for).returns(Gem::Version.new("99.0.0"))
        expect { doc.call }.to output(/\(update available\)/).to_stdout
      end

      describe "Rake" do
        before do
          load File.expand_path("../../../../../lib/capistrano/doctor.rb",
                                __FILE__)
        end

        after do
          Rake::Task.clear
        end

        it "has an doctor:gems task that calls GemsDoctor" do
          GemsDoctor.any_instance.expects(:call)
          Rake::Task["doctor:gems"].invoke
        end

        it "has a doctor task that depends on doctor:gems" do
          expect(Rake::Task["doctor"].prerequisites).to include("doctor:gems")
        end
      end
    end
  end
end
