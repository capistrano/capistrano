require 'spec_helper'

module Capistrano
  class Configuration

    describe Filter do
      let(:available) { [ Server.new('server1').add_roles([:web,:db]),
                          Server.new('server2').add_role(:web),
                          Server.new('server3').add_role(:redis),
                          Server.new('server4').add_role(:db) ] }

      describe '#new' do
        it "won't create an invalid type of filter" do
          expect {
            f = Filter.new(:zarg)
          }.to raise_error RuntimeError
        end

        it 'creates an empty host filter' do
          expect(Filter.new(:host).filter(available)).to be_empty
        end

        it 'creates a null host filter' do
          expect(Filter.new(:host, :all).filter(available)).to eq(available)
        end

        it 'creates an empty role filter' do
          expect(Filter.new(:role).filter(available)).to be_empty
        end

        it 'creates a null role filter' do
          expect(Filter.new(:role, :all).filter(available)).to eq(available)
        end

      end

      describe 'host filter' do
        it 'works with a single server' do
          set = Filter.new(:host, 'server1').filter(available.first)
          expect(set.map(&:hostname)).to eq(%w{server1})
        end
        it 'returns all hosts matching a string' do
          set = Filter.new(:host, 'server1').filter(available)
          expect(set.map(&:hostname)).to eq(%w{server1})
        end
        it 'returns all hosts matching a comma-separated string' do
          set = Filter.new(:host, 'server1,server3').filter(available)
          expect(set.map(&:hostname)).to eq(%w{server1 server3})
        end
        it 'returns all hosts matching an array of strings' do
          set = Filter.new(:host, %w{server1 server3}).filter(available)
          expect(set.map(&:hostname)).to eq(%w{server1 server3})
        end
        it 'returns all hosts matching regexp' do
          set = Filter.new(:host, 'server[13]$').filter(available)
          expect(set.map(&:hostname)).to eq(%w{server1 server3})
        end
        it 'correctly identifies a regex with a comma in' do
          set = Filter.new(:host, 'server\d{1,3}$').filter(available)
          expect(set.map(&:hostname)).to eq(%w{server1 server2 server3 server4})
        end
      end

      describe 'role filter' do
        it 'returns all hosts' do
          set = Filter.new(:role, [:all]).filter(available)
          expect(set.size).to eq(available.size)
          expect(set.first.hostname).to eq('server1')
        end
        it 'returns hosts in a single string role' do
          set = Filter.new(:role, 'web').filter(available)
          expect(set.size).to eq(2)
          expect(set.map(&:hostname)).to eq(%w{server1 server2})
        end
        it 'returns hosts in a single role' do
          set = Filter.new(:role, [:web]).filter(available)
          expect(set.size).to eq(2)
          expect(set.map(&:hostname)).to eq(%w{server1 server2})
        end
        it 'returns hosts in multiple roles specified by a string' do
          set = Filter.new(:role, 'web,db').filter(available)
          expect(set.size).to eq(3)
          expect(set.map(&:hostname)).to eq(%w{server1 server2 server4})
        end
        it 'returns hosts in multiple roles' do
          set = Filter.new(:role, [:web, :db]).filter(available)
          expect(set.size).to eq(3)
          expect(set.map(&:hostname)).to eq(%w{server1 server2 server4})
        end
        it 'returns hosts with regex role selection' do
          set = Filter.new(:role, /red/).filter(available)
          expect(set.map(&:hostname)).to eq(%w{server3})
        end
        it 'returns hosts with regex role selection using a string' do
          set = Filter.new(:role, '/red|web/').filter(available)
          expect(set.map(&:hostname)).to eq(%w{server1 server2 server3})
        end
        it 'returns hosts with combination of string role and regex' do
          set = Filter.new(:role, 'db,/red/').filter(available)
          expect(set.map(&:hostname)).to eq(%w{server1 server3 server4})
        end
      end
    end
  end
end
