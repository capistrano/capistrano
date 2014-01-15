require 'spec_helper'

module Capistrano
  module DSL

    class DummyStages
      include Stages
      include Paths
      include Env
    end

    describe Stages do
      before(:each) do
        @stage =  DummyStages.new
        @stage.stages = []
      end

      it "should return empty array if no stages are set" do
        expect(@stage.stages).to eq(Array.new)
      end

      it "should return empty array if directory is empty" do
        expect(@stage.stages).to eq(Array.new)
      end

      it "should return array of stages which were set before" do
        @stage.stages = "production", "dev", "staging"
        expect(@stage.stages).to eq(["production", "dev", "staging"])
      end

      it "should return array of stages which were set before" do
        @stage.stages = "production"
        expect(@stage.stages).to eq(["production"])
      end

      it "should overwrite previously set stages" do
        @stage.stages = "production", "dev", "staging"
        expect(@stage.stages).to eq(["production", "dev", "staging"])
        @stage.stages = "production", "dev", "staging2"
        expect(@stage.stages).to eq(["production", "dev", "staging2"])
      end

      describe "stage_definitions" do
        before(:each) do
          File.open("/tmp/stage.rb", "w") {}
          def @stage.stage_definitions
            "/tmp/*.rb"
          end
        end

        it "should return only stages in directory" do
          expect(@stage.stages).to eq(["stage"])
        end

        it "should return union of set and directory stages" do
          @stage.stages = "production", "dev"
          expect(@stage.stages).to eq(["stage","production", "dev"])
        end
      end
    end
  end
end
