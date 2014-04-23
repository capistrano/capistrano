require "bundler/gem_tasks"
require "cucumber/rake/task"
require "rspec/core/rake_task"

task :default => :spec
RSpec::Core::RakeTask.new

Cucumber::Rake::Task.new(:features)

