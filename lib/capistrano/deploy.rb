require 'capistrano/framework'
require 'capistrano-stats'

Capistrano::Application.load_rakefile_once File.expand_path("../tasks/deploy.rake", __FILE__)
