desc 'Install Capistrano'
task :install do
  tasks_dir = 'lib/deploy/tasks'
  config_dir = 'config/deploy' #TODO stages

  File.open('Capfile',  'w+', 0644) do |file|
    file.puts '#!/usr/bin/env cap'
    file.puts "require 'capistrano/install'"
    file.puts "# Loads any rake tasks from lib/deploy/tasks"
    file.puts "Dir.glob('#{tasks_dir}/*.rake').each { |r| import r }"
    file.puts
    file.puts "# Uncomment to require standard deployment tasks"
    file.puts "# require 'capistrano/rails'"
  end
  puts 'write Capfile'

  File.open('config/deploy.rb',  'w+', 0644) do |file|
    file.puts <<-CONFIG
# example configuration
Capistrano::Env.configure do |config|
  config.role :app, %w{example.com}
  config.role :web, %w{example.com}
  config.role :db, %w{example.com}
  config.user 'tomc'
  config.path '/var/www/my_app/current'
end
    CONFIG
  end
  puts 'write example config/deploy.rb'

  mkdir_p tasks_dir
  mkdir_p config_dir

  puts 'Capified'
end
