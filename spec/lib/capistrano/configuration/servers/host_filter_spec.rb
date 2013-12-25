require 'spec_helper'

module Capistrano
  class Configuration
    class Servers

      describe HostFilter do
        let(:host_filter) { HostFilter.new(available) }
        let(:available) { [ Server.new('server1'), Server.new('server2'), Server.new('server3') ] }

        describe '#new' do
          it 'takes one array of hostnames' do
            expect(host_filter)
          end
        end

        describe '.for' do

          subject { HostFilter.for(available) }

          context 'without env vars' do
            it 'returns all available hosts' do
              expect(subject).to eq available
            end
          end

          context 'with ENV vars' do
            before do
              ENV.stubs(:[]).with('HOSTS').returns('server1,server2')
            end

            it 'returns all required hosts defined in HOSTS' do
              expect(subject).to eq [Server.new('server1'), Server.new('server2')]
            end
          end

          context 'with configuration filters' do
            before do
              Configuration.env.set(:filter, hosts: %w{server1 server2})
            end

            it 'returns all required hosts defined in the filter' do
              expect(subject).to eq [Server.new('server1'), Server.new('server2')]
            end

            after do
              Configuration.env.delete(:filter)
            end
          end

          context 'with a single configuration filter' do
            before do
              Configuration.env.set(:filter, hosts: 'server3')
            end

            it 'returns all required hosts defined in the filter' do
              expect(subject).to eq [Server.new('server3')]
            end

            after do
              Configuration.env.delete(:filter)
            end
          end

          context 'with configuration filters and ENV vars' do
            before do
              Configuration.env.set(:filter, hosts: 'server1')
              ENV.stubs(:[]).with('HOSTS').returns('server3')
            end

            it 'returns all required hosts defined in the filter' do
              expect(subject).to eq [Server.new('server1'), Server.new('server3')]
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
