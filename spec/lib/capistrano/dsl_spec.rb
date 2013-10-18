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
      let(:glob) { [] }

      subject { dsl.stages }

      before do
        Dir.expects(:[]).with('config/deploy/**/*.rb').returns(glob)
      end

      context 'no files given' do
        it { should == [] }
      end

      context 'two files given' do
        let(:glob) do
          [
            'config/deploy/staging.rb',
            'config/deploy/production.rb'
          ]
        end
        it 'returns two simple stages' do
          subject.should == [
            'production',
            'staging'
          ]
        end
      end

      context 'two files and one root shared file given' do
        let(:glob) do
          [
            'config/deploy/staging.rb',
            'config/deploy/production.rb',
            'config/deploy.rb'
          ]
        end

        it 'returns two simple stages' do
          subject.should == [
            'production',
            'staging'
          ]
        end
      end

      context 'one directory with two files given' do
        let(:glob) do
          [
            'config/deploy/apps/staging.rb',
            'config/deploy/apps/production.rb'
          ]
        end
        it 'returns two namespaced stages' do
          subject.should == [
            'apps:production',
            'apps:staging'
          ]
        end
      end

      context 'one directory with two files and one shared file given' do
        let(:glob) do
          [
            'config/deploy/apps/staging.rb',
            'config/deploy/apps/production.rb',
            'config/deploy/apps.rb'
          ]
        end
        it 'returns two namespaced stages' do
          subject.should == [
            'apps:production',
            'apps:staging'
          ]
        end
      end

      context 'one directory with two files and one another file given' do
        let(:glob) do
          [
            'config/deploy/apps/staging.rb',
            'config/deploy/apps/production.rb',
            'config/deploy/stage.rb'
          ]
        end
        it 'returns two namespaced stages' do
          subject.should == [
            'apps:production',
            'apps:staging',
            'stage'
          ]
        end
      end

      context 'two directory with two files given' do
        let(:glob) do
          [
            'config/deploy/ns1/stage11.rb',
            'config/deploy/ns2/stage21.rb',
            'config/deploy/ns1/stage12.rb',
            'config/deploy/ns2/stage22.rb'
          ]
        end
        it 'returns four namespaced stages' do
          subject.should == [
            'ns1:stage11',
            'ns1:stage12',
            'ns2:stage21',
            'ns2:stage22'
          ]
        end
      end

      context 'two nested directory with two files and two shared given' do
        let(:glob) do
          [
            'config/deploy/ns1/ns2/stage1.rb',
            'config/deploy/ns1/ns2/stage2.rb'
          ]
        end
        it 'returns four namespaced stages' do
          subject.should == [
            'ns1:ns2:stage1',
            'ns1:ns2:stage2'
          ]
        end
      end

      context 'two nested directory with one file inside given' do
        let(:glob) do
          [
            'config/deploy/ns1/ns2/stage3.rb',
            'config/deploy/ns1/stage2.rb',
            'config/deploy/stage1.rb'
          ]
        end
        it 'returns three namespaced stages' do
          subject.should == [
            'ns1:ns2:stage3',
            'ns1:stage2',
            'stage1',
          ]
        end
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
