require 'spec_helper'

module Capistrano
  module DSL

    describe Env do

      let(:env) { Configuration.new }

      describe '#role' do

        it 'can add a role, with hosts' do
          env.role(:app, %w{example.com})
          env.roles_for(:app).first.hostname.should == "example.com"
        end

        it 'handles de-duplification within roles' do
          env.role(:app, %w{example.com})
          env.role(:app, %w{example.com})
          env.roles_for(:app).length.should == 1
        end

        it 'accepts instances of server objects' do
          pending
          env.role(:app, [Capistrano::Configuration::Server.new('example.net'), 'example.com'])
          env.roles_for(:app).length.should == 2
        end

        it 'accepts non-enumerable types' do
          env.role(:app, 'example.com')
          env.roles_for(:app).length.should == 1
        end

      end

      describe '#server' do

        it "can create a server with properties" do
          env.server('example.com', roles: [:app, "web"], my: :value)
          env.roles_for(:app).first.hostname.should == 'example.com'
          env.roles_for(:web).first.hostname.should == 'example.com'
          env.roles_for(:all).first.properties.my.should == :value
        end

      end

      describe '#roles' do

        before do
          env.server('example.com', roles: :app, active: true)
          env.server('example.org', roles: :app)
        end

        it 'raises if the filter would remove all matching hosts' do
          pending
          env.server('example.org', active: true)
          lambda do
            env.roles_for(:app, filter: lambda { |s| !s.properties.active })
          end.should raise_error
        end

        it 'can filter hosts by properties on the host object using symbol as shorthand' do
          env.roles_for(:app, filter: :active).length.should == 1
        end

        it 'can select hosts by properties on the host object using symbol as shorthand' do
          env.roles_for(:app, select: :active).length.should == 1
        end

        it 'can filter hosts by properties on the host using a regular proc' do
          env.roles_for(:app, filter: lambda { |h| h.properties.active } ).length.should == 1
        end

        it 'can select hosts by properties on the host using a regular proc' do
          env.roles_for(:app, select: lambda { |h| h.properties.active } ).length.should == 1
        end

      end

    end

  end
end
