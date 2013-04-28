require 'spec_helper'

module Capistrano
  class Configuration
    describe Servers do
      let(:servers) { Servers.new }

      describe 'adding a role' do
        subject { servers.add_role(:app, %w{1 2}) }

        it 'adds two new server instances' do
          expect{subject}.to change{servers.count}.from(0).to(2)
        end
      end

      describe 'adding a role to an existing server' do
        before do
          servers.add_role(:web, %w{1 2})
          servers.add_role(:app, %w{1 2})
        end

        it 'adds new roles to existing servers' do
          expect(servers.count).to eq 2
        end
      end

      describe 'collecting server roles' do
        let(:app) { Set.new([:app]) }
        let(:web_app) { Set.new([:web, :app]) }
        let(:web) { Set.new([:web]) }

        before do
          servers.add_role(:app, %w{1 2 3})
          servers.add_role(:web, %w{2 3 4})
        end

        it 'returns an array of the roles' do
          expect(servers.fetch_roles([:app]).collect(&:roles)).to eq [app, web_app, web_app]
          expect(servers.fetch_roles([:web]).collect(&:roles)).to eq [web_app, web_app, web]
        end
      end

      describe 'fetching servers' do
        before do
          servers.add_role(:app, %w{1 2})
          servers.add_role(:web, %w{2 3})
        end

        it 'returns the correct app servers' do
          expect(servers.fetch_roles([:app]).map(&:hostname)).to eq %w{1 2}
        end

        it 'returns the correct web servers' do
          expect(servers.fetch_roles([:web]).map(&:hostname)).to eq %w{2 3}
        end

        it 'returns the correct app and web servers' do
          expect(servers.fetch_roles([:app, :web]).map(&:hostname)).to eq %w{1 2 3}
        end

        it 'returns all servers' do
          expect(servers.fetch_roles([:all]).map(&:hostname)).to eq %w{1 2 3}
        end
      end
    end
  end
end
