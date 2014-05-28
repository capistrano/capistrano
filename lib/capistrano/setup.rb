require 'capistrano/dsl'

namespace :load do
  task :defaults do
    require 'capistrano/defaults.rb'
  end
end

stages.each do |stage|
  Rake::Task.define_task(stage) do |current_task|
    set(:stage, stage.to_sym)

    invoke 'load:defaults'

    (found_capfile, capfile_location) = current_task.application.find_rakefile_location
    capfile_location = Dir.pwd unless found_capfile

    require File.expand_path(deploy_config_path, capfile_location)
    require File.expand_path(stage_config_path.join("#{stage}.rb"), capfile_location)

    require "capistrano/#{fetch(:scm)}.rb"

    I18n.locale = fetch(:locale, :en)
    configure_backend
  end
end

require 'capistrano/dotfile'
