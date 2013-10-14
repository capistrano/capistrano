include Capistrano::DSL

namespace :load do
  task :defaults do
    load 'capistrano/defaults.rb'
  end
end

stages.each do |stage|
  Rake::Task.define_task(stage) do
    invoke 'load:defaults'
    load deploy_config_path
    load stage_config_path.join("#{stage}.rb")
    load "capistrano/#{fetch(:scm)}.rb"
    set(:stage, stage.to_sym)
    I18n.locale = fetch(:locale, :en)
    configure_backend
  end
end

require 'capistrano/dotfile'
