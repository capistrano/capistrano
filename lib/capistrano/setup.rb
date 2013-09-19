include Capistrano::DSL

namespace :load do
  task :defaults do
    load 'capistrano/defaults.rb'
    load 'config/deploy.rb'
  end
end

stages.each do |stage|
  Rake::Task.define_task(stage) do
    invoke 'load:defaults'
    set(:stage, stage.to_sym)
    load "config/deploy/#{stage}.rb"
    load "capistrano/#{fetch(:scm)}.rb"
    I18n.locale = fetch(:locale, :en)
    configure_backend
  end
end

require 'capistrano/dotfile'
