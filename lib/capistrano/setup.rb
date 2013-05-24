include Capistrano::DSL

load 'capistrano/defaults.rb'

stages.each do |stage|
  Rake::Task.define_task(stage) do
    load "config/deploy.rb"
    load "config/deploy/#{stage}.rb"
    load "capistrano/#{fetch(:scm)}.rb"
    set(:stage, stage.to_sym)
    I18n.locale = fetch(:locale, :en)
    configure_backend
  end
end


require 'capistrano/dotfile'
