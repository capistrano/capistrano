require 'spec_helper'

module Capistrano
  module DSL

    class DummyEnv
      include Env
    end

    describe Env do
      let(:env) { DummyEnv.new }

      context 'set' do
        it 'accepts value' do
          set = env.set('key', 'value')
          expect(set).to eq('value')
        end

        it 'accepts block' do
          set = env.set('key') { 'block' }
          expect(set).to be_a(Proc)
        end

        it 'raises argument error when only one params is passed' do
          expect{ env.set('key') }.to raise_error(ArgumentError, 'wrong number of arguments (1 for 2)')
        end
      end

    end
  end
end
