include Capistrano::DSL

stages.each do |stage|
  Rake::Task.define_task(stage) do
    load "config/deploy.rb"
    load "config/deploy/#{stage}.rb"
    set(:stage, stage.to_sym)
    configure_backend
  end
end
