require "spec_helper"
require "rake"
require "capistrano/dsl"
require "capistrano/rake_monkey_patch"

module Rake
  describe Task do
    before do
      Rake::Task.__send__ :include, Capistrano::TaskEnhancements
    end

    after do
      # Ensure that any tasks we create in these tests don't pollute other tests
      Rake::Task.clear
    end

    it "reinvoking a task will print a message on stderr" do
      Rake::Task.define_task("some_task")

      Rake::Task["some_task"].invoke
      expect do
        Rake::Task["some_task"].invoke
      end.to output(/^.*Warning: Reinvoking `some_task' from .* - Task will be silently skipped/).to_stderr
    end
  end
end
