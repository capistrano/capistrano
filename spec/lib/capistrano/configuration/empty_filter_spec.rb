require "spec_helper"

module Capistrano
  class Configuration
    describe EmptyFilter do
      subject(:empty_filter) { EmptyFilter.new }

      describe "#filter" do
        let(:servers) { mock("servers") }

        it "returns an empty array" do
          expect(empty_filter.filter(servers)).to eq([])
        end
      end
    end
  end
end
