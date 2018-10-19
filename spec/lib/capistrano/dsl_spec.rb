require "spec_helper"

module Capistrano
  class DummyDSL
    include DSL
  end

  # see also - spec/integration/dsl_spec.rb
  describe DSL do
    let(:dsl) { DummyDSL.new }

    describe "#t" do
      before do
        I18n.expects(:t).with(:phrase, count: 2, scope: :capistrano)
      end

      it "delegates to I18n" do
        dsl.t(:phrase, count: 2)
      end
    end

    describe "#stage_set?" do
      subject { dsl.stage_set? }

      context "stage is set" do
        before do
          dsl.set(:stage, :sandbox)
        end
        it { expect(subject).to be_truthy }
      end

      context "stage is not set" do
        before do
          dsl.set(:stage, nil)
        end
        it { expect(subject).to be_falsey }
      end
    end

    describe "#sudo" do
      before do
        dsl.expects(:execute).with(:sudo, :my, :command)
      end

      it "prepends sudo, delegates to execute" do
        dsl.sudo(:my, :command)
      end
    end

    describe "#execute" do
      context "use outside of on scope" do
        after do
          task.clear
          Rake::Task.clear
        end

        let(:task) do
          Rake::Task.define_task("execute_outside_scope") do
            dsl.execute "whoami"
          end
        end

        it "prints helpful message to stderr", capture_io: true do
          expect do
            expect do
              task.invoke
            end.to output(/^.*Warning: `execute' should be wrapped in an `on' scope/).to_stderr
          end.to raise_error(NoMethodError)
        end
      end
    end

    describe "#invoke" do
      context "reinvoking" do
        it "will not reenable invoking task", capture_io: true do
          counter = 0

          Rake::Task.define_task("A") do
            counter += 1
          end

          expect do
            dsl.invoke("A")
            dsl.invoke("A")
          end.to change { counter }.by(1)
        end

        it "will print a message on stderr", capture_io: true do
          Rake::Task.define_task("B")

          expect do
            dsl.invoke("B")
            dsl.invoke("B")
          end.to output(/If you really meant to run this task again, use invoke!/).to_stderr
        end
      end
    end

    describe "#invoke!" do
      context "reinvoking" do
        it "will reenable invoking task", capture_io: true do
          counter = 0

          Rake::Task.define_task("C") do
            counter += 1
          end

          expect do
            dsl.invoke!("C")
            dsl.invoke!("C")
          end.to change { counter }.by(2)
        end

        it "will not print a message on stderr", capture_io: true do
          Rake::Task.define_task("D")

          expect do
            dsl.invoke!("D")
            dsl.invoke!("D")
          end.to_not output(/If you really meant to run this task again, use invoke!/).to_stderr
        end
      end
    end
  end
end
