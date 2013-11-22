require 'spec_helper'

module Capistrano
  class Configuration
    describe Server do
      let(:server) { Server.new('hostname:1234') }

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
        subject { server.matches? Server[hostname] }

        context 'with the same hostname' do
          let(:hostname) { 'hostname:1234' }
          it { should be_true }
        end

        context 'with the same hostname and a user' do
          let(:hostname) { 'user@hostname:1234' }
          it { should be_true }
        end

        context 'with the same hostname but different port' do
          let(:hostname) { 'hostname:5678' }
          it { should be_false }
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
            server.set(:primary, true)
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

        context 'properties contains user' do
          let(:properties) { {user: 'tomc'} }

          it 'sets the user' do
            expect(server.user).to eq 'tomc'
          end
        end

        context 'properties contains port' do
          let(:properties) { {port: 2222} }

          it 'sets the port' do
            expect(server.port).to eq 2222
          end
        end

        context 'properties contains key' do
          let(:properties) { {key: '/key'} }

          it 'adds the key' do
            expect(server.keys).to include '/key'
          end
        end

        context 'properties contains password' do
          let(:properties) { {password: 'supersecret'} }

          it 'adds the key' do
            expect(server.password).to eq 'supersecret'
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

          it 'keeps the existing properties' do
            expect(server.properties.webscales).to eq 6
            server.properties.webscales = 5
            expect(server.properties.webscales).to eq 5
          end
        end
      end

      describe '#include?' do
        let(:options) { {} }

        subject { server.select?(options) }

        before do
          server.properties.active = true
        end

        context 'options are empty' do
          it { should be_true }
        end

        context 'value is a symbol' do
          context 'value matches server property' do

            context 'with :filter' do
              let(:options) { { filter: :active }}
              it { should be_true }
            end

            context 'with :select' do
              let(:options) { { select: :active }}
              it { should be_true }
            end

            context 'with :exclude' do
              let(:options) { { exclude: :active }}
              it { should be_false }
            end
          end

          context 'value does not match server properly' do
            context 'with :filter' do
              let(:options) { { filter: :inactive }}
              it { should be_false }
            end

            context 'with :select' do
              let(:options) { { select: :inactive }}
              it { should be_false }
            end

            context 'with :exclude' do
              let(:options) { { exclude: :inactive }}
              it { should be_true }
            end
          end
        end

        context 'value is a proc' do
          context 'value matches server property' do

            context 'with :filter' do
              let(:options) { { filter: ->(s) { s.properties.active } } }
              it { should be_true }
            end

            context 'with :select' do
              let(:options) { { select: ->(s) { s.properties.active } } }
              it { should be_true }
            end

            context 'with :exclude' do
              let(:options) { { exclude: ->(s) { s.properties.active } } }
              it { should be_false }
            end

          end

          context 'value does not match server properly' do
            context 'with :filter' do
              let(:options) { { filter: ->(s) { s.properties.inactive } } }
              it { should be_false }
            end

            context 'with :select' do
              let(:options) { { select: ->(s) { s.properties.inactive } } }
              it { should be_false }
            end

            context 'with :exclude' do
              let(:options) { { exclude: ->(s) { s.properties.inactive } } }
              it { should be_true }
            end

          end
        end

      end

      describe 'assign ssh_options' do
        let(:server) { Server.new('user_name@hostname') }

        context 'defaults' do
          it 'forward agent' do
            expect(server.netssh_options[:forward_agent]).to eq true
          end
          it 'contains user' do
            expect(server.netssh_options[:user]).to eq 'user_name'
          end
        end

        context 'custom' do
          let(:properties) do
            { ssh_options: {
              user: 'another_user',
              keys: %w(/home/another_user/.ssh/id_rsa),
              forward_agent: false,
              auth_methods: %w(publickey password) } }
          end

          before do
            server.with(properties)
          end

          it 'not forward agent' do
            expect(server.netssh_options[:forward_agent]).to eq false
          end
          it 'contains correct user' do
            expect(server.netssh_options[:user]).to eq 'another_user'
          end
          it 'contains keys' do
            expect(server.netssh_options[:keys]).to eq %w(/home/another_user/.ssh/id_rsa)
          end
          it 'contains auth_methods' do
            expect(server.netssh_options[:auth_methods]).to eq %w(publickey password)
          end
        end

      end

      describe ".[]" do
        it 'creates a server if its argument is not already a server' do
          expect(Server['hostname:1234']).to be_a Server
        end

        it 'returns its argument if it is already a server' do
          expect(Server[server]).to be server
        end
      end
    end
  end
end
