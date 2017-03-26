require "spec_helper"

module Capistrano
  class Configuration
    describe Filter do
      let(:available) do
        [
          Server.new("server1").add_roles(%i(web db)),
          Server.new("server2").add_role(:web),
          Server.new("server3").add_role(:redis),
          Server.new("server4").add_role(:db),
          Server.new("server5").add_role(:stageweb)
        ]
      end

      describe "#new" do
        it "won't create an invalid type of filter" do
          expect do
            Filter.new(:zarg)
          end.to raise_error RuntimeError
        end

        context "with type :host" do
          context "and no values" do
            it "creates an EmptyFilter strategy" do
              expect(Filter.new(:host).instance_variable_get(:@strategy)).to be_a(EmptyFilter)
            end
          end

          context "and :all" do
            it "creates an NullFilter strategy" do
              expect(Filter.new(:host, :all).instance_variable_get(:@strategy)).to be_a(NullFilter)
            end
          end

          context "and [:all]" do
            it "creates an NullFilter strategy" do
              expect(Filter.new(:host, [:all]).instance_variable_get(:@strategy)).to be_a(NullFilter)
            end
          end

          context "and [:all]" do
            it "creates an NullFilter strategy" do
              expect(Filter.new(:host, "all").instance_variable_get(:@strategy)).to be_a(NullFilter)
            end
          end
        end

        context "with type :role" do
          context "and no values" do
            it "creates an EmptyFilter strategy" do
              expect(Filter.new(:role).instance_variable_get(:@strategy)).to be_a(EmptyFilter)
            end
          end

          context "and :all" do
            it "creates an NullFilter strategy" do
              expect(Filter.new(:role, :all).instance_variable_get(:@strategy)).to be_a(NullFilter)
            end
          end

          context "and [:all]" do
            it "creates an NullFilter strategy" do
              expect(Filter.new(:role, [:all]).instance_variable_get(:@strategy)).to be_a(NullFilter)
            end
          end

          context "and [:all]" do
            it "creates an NullFilter strategy" do
              expect(Filter.new(:role, "all").instance_variable_get(:@strategy)).to be_a(NullFilter)
            end
          end
        end
      end

      describe "#filter" do
        let(:strategy) { filter.instance_variable_get(:@strategy) }
        let(:results) { mock("result") }

        shared_examples "it calls #filter on its strategy" do
          it "calls #filter on its strategy" do
            strategy.expects(:filter).with(available).returns(results)
            expect(filter.filter(available)).to eq(results)
          end
        end

        context "for an empty filter" do
          let(:filter) { Filter.new(:role) }
          it_behaves_like "it calls #filter on its strategy"
        end

        context "for a null filter" do
          let(:filter) { Filter.new(:role, :all) }
          it_behaves_like "it calls #filter on its strategy"
        end

        context "for a role filter" do
          let(:filter) { Filter.new(:role, "web") }
          it_behaves_like "it calls #filter on its strategy"
        end

        context "for a host filter" do
          let(:filter) { Filter.new(:host, "server1") }
          it_behaves_like "it calls #filter on its strategy"
        end
      end
    end
  end
end
