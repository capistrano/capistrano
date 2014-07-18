require 'capistrano/framework'

Capistrano::Application.load_rakefile_once File.expand_path("../tasks/deploy.rake", __FILE__)
