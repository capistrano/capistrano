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

      describe 'adding roles' do
        subject { server.add_roles([:things, :stuff]) }
        it 'adds the roles' do
          expect{subject}.to change{server.roles.size}.from(0).to(2)
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

      describe 'identifying as primary' do
        subject { server.primary }
        context 'server is primary' do
          before do
            server.properties.primary = true
          end
          it 'returns self' do
            expect(subject).to eq server
          end
        end

        context 'server is not primary' do
          it 'is falesy' do
            expect(subject).to be_false
          end
        end
      end

      describe 'assigning properties' do

        before do
          server.with(properties)
        end

        context 'properties contains roles' do
          let(:properties) { {roles: [:clouds]} }

          it 'adds the roles' do
            expect(server.roles.first).to eq :clouds
          end
        end

        context 'new properties' do
          let(:properties) { { webscales: 5 } }

          it 'adds the properties' do
            expect(server.properties.webscales).to eq 5
          end
        end

        context 'existing properties' do
          let(:properties) { { webscales: 6 } }

          before do
            server.properties.webscales = 5
          end

          it 'does keeps the existing properties' do
            expect(server.properties.webscales).to eq 5
          end
        end
      end

    end
  end
end
