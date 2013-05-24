require 'spec_helper'

module Capistrano
  class Configuration
    describe Server do
      let(:server) { Server.new('hostname') }

      describe 'adding a role' do
        subject { server.add_role(:test) }
        it 'adds the role' do
          expect{subject}.to change{server.roles.size}.from(0).to(1)
        end
      end

      describe 'checking roles' do
        subject { server.has_role?(:test) }

        before do
          server.add_role(:test)
        end

        it 'adds the role' do
          expect{subject}.to be_true
        end
      end

      describe 'comparing identity' do
        subject { server.matches? hostname }

        context 'with the same hostname' do
          let(:hostname) { 'hostname' }
          it { should be_true }
        end

        context 'with the same hostname and a user' do
          let(:hostname) { 'user@hostname' }
          it { should be_true }
        end

        context 'with a different hostname' do
          let(:hostname) { 'otherserver' }
          it { should be_false }
        end
      end

    end
  end
end
