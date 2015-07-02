require 'spec_helper'
require 'rake'
require 'capistrano/immutable_task'

module Capistrano
  describe ImmutableTask do
    it 'prints warning and raises when task is enhanced' do
      extend(Rake::DSL)

      load_defaults = Rake::Task.define_task('load:defaults')
      load_defaults.extend(Capistrano::ImmutableTask)

      $stderr.expects(:puts).with do |message|
        message =~ /^WARNING: load:defaults has already been invoked/
      end

      expect {
        namespace :load do
          task :defaults do
            # Never reached since load_defaults is frozen and can't be enhanced
          end
        end
      }.to raise_error(/frozen/i)
    end
  end
end
