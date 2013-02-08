include Capistrano::DSL


stages.each do |stage|
  Rake::Task.define_task(stage) do
    load "config/deploy/#{stage}.rb"
    set(:stage, stage.to_sym)
    configure_ssh_kit
  end
end

namespace :deploy do

  desc "starting"
  task :starting do
  end

  desc "start"
  task :start do
  end

  desc "update"
  task :update do
  end

  desc "finalize"
  task :finalize do
  end

  desc "restart"
  task :restart do
  end

  desc "finishing"
  task :finishing do
  end

  desc "finished"
  task :finished do
  end

  before :starting, :ensure_stage do
    unless stage_set?
      puts t(:stage_not_set)
      exit 1
    end
  end
end

desc "Deploy"
task :deploy do
  %w{starting start update finalize restart finishing finished}.each do |stage|
    invoke "deploy:#{stage}"
  end
end
task default: :deploy
