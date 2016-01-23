require "bundler/gem_tasks"
require "cucumber/rake/task"
require "rspec/core/rake_task"
require "rubocop/rake_task"

task :default => [:spec, :lint]
RSpec::Core::RakeTask.new

Cucumber::Rake::Task.new(:features)

desc "Run RuboCop lint checks"
RuboCop::RakeTask.new(:lint) do |task|
  task.options = ["--lint"]
end
