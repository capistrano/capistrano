require 'spec_helper'

module Capistrano

  class DummyDSL
    include DSL
  end

  # see also - spec/integration/dsl_spec.rb
  describe DSL do
    let(:dsl) { DummyDSL.new }

    describe '#t' do
      before do
        I18n.expects(:t).with(:phrase, {count: 2, scope: :capistrano})
      end

      it 'delegates to I18n' do
        dsl.t(:phrase, count: 2)
      end
    end

    describe '#stages' do
      before do
        Dir.expects(:[]).with('config/deploy/*.rb').
          returns(['config/deploy/staging.rb', 'config/deploy/production.rb'])
      end

      it 'returns a list of defined stages' do
        expect(dsl.stages).to eq %w{staging production}
      end
    end

    describe '#stage_set?' do
      subject { dsl.stage_set? }

      context 'stage is set' do
        before do
          dsl.set(:stage, :sandbox)
        end
        it { should be_true }
      end

      context 'stage is not set' do
        before do
          dsl.set(:stage, nil)
        end
        it { should be_false }
      end
    end

    describe '#sudo' do

      before do
        dsl.expects(:execute).with(:sudo, :my, :command)
      end

      it 'prepends sudo, delegates to execute' do
        dsl.sudo(:my, :command)
      end
    end
  end
end
