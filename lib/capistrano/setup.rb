include Capistrano::DSL

namespace :load do
  task :defaults do
    load 'capistrano/defaults.rb'
  end
end

stages.each do |stage|
  Rake::Task.define_task(stage) do
    set(:stage, stage.to_sym)
    
    invoke 'load:defaults'
    load 'config/deploy.rb'
    load "config/deploy/#{stage}.rb"
    load "capistrano/#{fetch(:scm)}.rb"
    I18n.locale = fetch(:locale, :en)
    configure_backend
  end
end

require 'capistrano/dotfile'
