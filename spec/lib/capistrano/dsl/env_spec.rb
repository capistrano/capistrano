require 'spec_helper'

module Capistrano
  module DSL

    describe Env do

      let(:env) { Configuration.env }

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

        end

        it 'can filter hosts by properties on the host object' do
          1+1
        end

      end

    end

  end
end
