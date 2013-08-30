require 'spec_helper'

module Capistrano
  class Configuration
    class Servers

      describe RoleFilter do
        let(:role_filter) { RoleFilter.new(required, available) }
        let(:required) { [] }
        let(:available) { [:web, :app, :db] }

        describe '#new' do
          it 'takes two arrays of role names' do
            expect(role_filter)
          end
        end

        describe '.for' do

          subject { RoleFilter.for(required, available) }

          context 'without env vars' do
            context ':all required' do
              let(:required) { [:all] }

              it 'returns all available names' do
                expect(subject).to eq available
              end
            end

            context 'role names required' do
              let(:required) { [:web, :app] }
              it 'returns all required names' do
                expect(subject).to eq required
              end
            end
          end

          context 'with ENV vars' do
            before do
              ENV.stubs(:[]).with('ROLES').returns('app,web')
            end

            context ':all required' do
              let(:required) { [:all] }

              it 'returns available names defined in ROLES' do
                expect(subject).to eq [:app, :web]
              end
            end

            context 'role names required' do
              let(:required) { [:web, :db] }
              it 'returns all required names defined in ROLES' do
                expect(subject).to eq [:web]
              end
            end
          end

          context 'with configuration filters' do
            before do
              Configuration.env.set(:filter, roles: %w{app web})
            end

            context ':all required' do
              let(:required) { [:all] }

              it 'returns available names defined in the filter' do
                expect(subject).to eq [:app, :web]
              end
            end

            context 'role names required' do
              let(:required) { [:web, :db] }
              it 'returns all required names defined in the filter' do
                expect(subject).to eq [:web]
              end
            end

            after do
              Configuration.env.delete(:filter)
            end
          end

          context 'with a single configuration filter' do
            before do
              Configuration.env.set(:filter, roles: 'web')
            end

            context ':all required' do
              let(:required) { [:all] }

              it 'returns available names defined in the filter' do
                expect(subject).to eq [:web]
              end
            end

            context 'role names required' do
              let(:required) { [:web, :db] }
              it 'returns all required names defined in the filter' do
                expect(subject).to eq [:web]
              end
            end

            after do
              Configuration.env.delete(:filter)
            end
          end

          context 'with configuration filters and ENV vars' do
            before do
              Configuration.env.set(:filter, roles: %w{app})
              ENV.stubs(:[]).with('ROLES').returns('web')
            end

            context ':all required' do
              let(:required) { [:all] }

              it 'returns available names defined in the filter' do
                expect(subject).to eq [:web, :app]
              end
            end

            context 'role names required' do
              let(:required) { [:web, :db] }
              it 'returns all required names defined in the filter' do
                expect(subject).to eq [:web]
              end
            end

            after do
              Configuration.env.delete(:filter)
            end
          end
        end
      end

    end
  end
end
