require "spec_helper"
require "capistrano/doctor/servers_doctor"

module Capistrano
  module Doctor
    describe ServersDoctor do
      include Capistrano::DSL
      let(:doc) { ServersDoctor.new }

      before { Capistrano::Configuration.reset! }
      after { Capistrano::Configuration.reset! }

      it "prints using 4-space indentation" do
        expect { doc.call }.to output(/^ {4}/).to_stdout
      end

      it "prints the number of defined servers" do
        role :app, %w(example.com)
        server "www@example.com:22"

        expect { doc.call }.to output(/Servers \(2\)/).to_stdout
      end

      describe "prints the server's details" do
        it "including username" do
          server "www@example.com"
          expect { doc.call }.to output(/www@example.com/).to_stdout
        end

        it "including port" do
          server "www@example.com:22"
          expect { doc.call }.to output(/www@example.com:22/).to_stdout
        end

        it "including roles" do
          role :app, %w(example.com)
          expect { doc.call }.to output(/example.com\s+\[:app\]/).to_stdout
        end

        it "including empty roles" do
          server "example.com"
          expect { doc.call }.to output(/example.com\s+\[\]/).to_stdout
        end

        it "including properties" do
          server "example.com", roles: %w(app db), primary: true
          expect { doc.call }.to \
            output(/example.com\s+\[:app, :db\]\s+\{ :primary => true \}/).to_stdout
        end

        it "including misleading role name alert" do
          server "example.com", roles: ["web app db"]
          warning_msg = 'Whitespace detected in role(s) :"web app db". ' \
            'This might be a result of a mistyped "%w()" array literal'

          expect { doc.call }.to output(/#{Regexp.escape(warning_msg)}/).to_stdout
        end
      end

      it "doesn't fail for no servers" do
        expect { doc.call }.to output("\nServers (0)\n    \n").to_stdout
      end

      describe "Rake" do
        before do
          load File.expand_path("../../../../../lib/capistrano/doctor.rb",
                                __FILE__)
        end

        after do
          Rake::Task.clear
        end

        it "has an doctor:servers task that calls ServersDoctor" do
          ServersDoctor.any_instance.expects(:call)
          Rake::Task["doctor:servers"].invoke
        end

        it "has a doctor task that depends on doctor:servers" do
          expect(Rake::Task["doctor"].prerequisites).to \
            include("doctor:servers")
        end
      end
    end
  end
end
