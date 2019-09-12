require "bundler/gem_tasks"
require "cucumber/rake/task"
require "rspec/core/rake_task"
require "rubocop/rake_task"

task default: %i(spec rubocop)
RSpec::Core::RakeTask.new

Cucumber::Rake::Task.new(:features)

desc "Run RuboCop checks"
RuboCop::RakeTask.new

Rake::Task["release"].enhance do
  puts "Don't forget to publish the release on GitHub!"
  system "open https://github.com/capistrano/capistrano/releases"
end
