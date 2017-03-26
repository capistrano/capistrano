require "spec_helper"

module Capistrano
  class Configuration
    describe RoleFilter do
      subject(:role_filter) { RoleFilter.new(values) }

      let(:available) do
        [
          Server.new("server1").add_roles(%i(web db)),
          Server.new("server2").add_role(:web),
          Server.new("server3").add_role(:redis),
          Server.new("server4").add_role(:db),
          Server.new("server5").add_role(:stageweb),
          Server.new("server6").add_role(:"db.new")
        ]
      end

      shared_examples "it filters roles correctly" do |expected_size, expected|
        it "filters correctly" do
          set = role_filter.filter(available)
          expect(set.size).to eq(expected_size)
          expect(set.map(&:hostname)).to eq(expected)
        end
      end

      describe "#filter" do
        context "with a single role string" do
          let(:values) { "web" }
          it_behaves_like "it filters roles correctly", 2, %w{server1 server2}
        end

        context "with a single role" do
          let(:values) { [:web] }
          it_behaves_like "it filters roles correctly", 2, %w{server1 server2}
        end

        context "with multiple roles in a string" do
          let(:values) { "web,db" }
          it_behaves_like "it filters roles correctly", 3, %w{server1 server2 server4}
        end

        context "with multiple roles" do
          let(:values) { %i(web db) }
          it_behaves_like "it filters roles correctly", 3, %w{server1 server2 server4}
        end

        context "with a regex" do
          let(:values) { /red/ }
          it_behaves_like "it filters roles correctly", 1, %w{server3}
        end

        context "with a regex string" do
          let(:values) { "/red|web/" }
          it_behaves_like "it filters roles correctly", 4, %w{server1 server2 server3 server5}
        end

        context "with both a string and regex" do
          let(:values) { "db,/red/" }
          it_behaves_like "it filters roles correctly", 3, %w{server1 server3 server4}
        end

        context "with a dot wildcard" do
          let(:values) { "db.*" }
          it_behaves_like "it filters roles correctly", 0, %w{}
        end

        context "with a dot" do
          let(:values) { "db.new" }
          it_behaves_like "it filters roles correctly", 1, %w{server6}
        end

        context "with a dot wildcard regex" do
          let(:values) { "/db.*/" }
          it_behaves_like "it filters roles correctly", 3, %w{server1 server4 server6}
        end
      end
    end
  end
end
