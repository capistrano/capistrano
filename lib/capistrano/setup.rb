require "capistrano/doctor"
require "capistrano/immutable_task"
include Capistrano::DSL

namespace :load do
  task :defaults do
    load "capistrano/defaults.rb"
  end
end

require "airbrussh/capistrano"
# We don't need to show the "using Airbrussh" banner announcement since
# Airbrussh is now the built-in formatter. Also enable command output by
# default; hiding the output might be confusing to users new to Capistrano.
Airbrussh.configure do |airbrussh|
  airbrussh.banner = false
  airbrussh.command_output = true
end

stages.each do |stage|
  Rake::Task.define_task(stage) do
    set(:stage, stage.to_sym)

    invoke "load:defaults"
    Rake.application["load:defaults"].extend(Capistrano::ImmutableTask)
    env.variables.untrusted! do
      load deploy_config_path
      load stage_config_path.join("#{stage}.rb")
    end
    configure_scm
    I18n.locale = fetch(:locale, :en)
    configure_backend
  end
end

require "capistrano/dotfile"
