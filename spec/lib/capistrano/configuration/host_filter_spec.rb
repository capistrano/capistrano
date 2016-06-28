require "spec_helper"

module Capistrano
  class Configuration
    describe HostFilter do
      subject(:host_filter) { HostFilter.new(values) }

      let(:available) do
        [Server.new("server1"),
         Server.new("server2"),
         Server.new("server3"),
         Server.new("server4"),
         Server.new("server5")]
      end

      shared_examples "it filters hosts correctly" do |expected|
        it "filters correctly" do
          set = host_filter.filter(available)
          expect(set.map(&:hostname)).to eq(expected)
        end
      end

      describe "#filter" do
        context "with a string" do
          let(:values) { "server1" }
          it_behaves_like "it filters hosts correctly", %w{server1}

          context "and a single server" do
            let(:available) { Server.new("server1") }
            it_behaves_like "it filters hosts correctly", %w{server1}
          end
        end

        context "with a comma separated string" do
          let(:values) { "server1,server3" }
          it_behaves_like "it filters hosts correctly", %w{server1 server3}
        end

        context "with an array of strings" do
          let(:values) { %w{server1 server3} }
          it_behaves_like "it filters hosts correctly", %w{server1 server3}
        end

        context "with a regexp" do
          let(:values) { "server[13]$" }
          it_behaves_like "it filters hosts correctly", %w{server1 server3}
        end

        context "with a regexp with line boundaries" do
          let(:values) { "^server" }
          it_behaves_like "it filters hosts correctly", %w{server1 server2 server3 server4 server5}
        end

        context "with a regexp with a comma" do
          let(:values) { 'server\d{1,3}$' }
          it_behaves_like "it filters hosts correctly", %w{server1 server2 server3 server4 server5}
        end
      end
    end
  end
end
