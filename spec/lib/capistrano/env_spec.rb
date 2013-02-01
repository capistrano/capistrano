require 'spec_helper'

module Capistrano
  describe Env do

    describe ".configure" do
      let(:configuration) { Env.configuration }

      it "configures" do
        Env.configure do |config|
          config.role :app, %w{example.com}
          config.role :web, %w{example.com}
          config.role :db, %w{example.com}
          config.user 'tomc'
          config.path '/var/www/my_app/current'
        end

        expect(configuration.roles).to eq({
          app: %w{example.com},
          web: %w{example.com},
          db: %w{example.com},
        })
        expect(configuration.user).to eq 'tomc'
        expect(configuration.path).to eq '/var/www/my_app/current'
      end
    end

    let(:env) { Env.new }

    describe "#role" do
      it "adds a role" do
        env.role(:app, %w{example.com})
        expect(env.roles).to eq({app: %w{example.com}})
      end
    end

    describe "#respond_to?" do
      context "key is set" do
        it "returns true" do
          env.this_is_a_test true
          expect(env.respond_to?(:this_is_a_test)).to be_true
        end
      end

      context "key is not set" do
        it "returns false" do
          expect(env.respond_to?(:this_is_a_test)).to be_false
        end
      end
    end
  end
end
