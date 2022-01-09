require "bundler/gem_tasks"
require "cucumber/rake/task"
require "rspec/core/rake_task"

begin
  require "rubocop/rake_task"
  desc "Run RuboCop checks"
  RuboCop::RakeTask.new
  task default: %i(spec rubocop)
rescue LoadError
  task default: :spec
end

RSpec::Core::RakeTask.new
Cucumber::Rake::Task.new(:features)

Rake::Task["release"].enhance do
  puts "Don't forget to publish the release on GitHub!"
  system "open https://github.com/capistrano/capistrano/releases"
end
