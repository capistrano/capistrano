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
    puts t(:starting)
  end

  desc "start"
  task :start do
    puts t(:start)
  end

  desc "update"
  task :update do
    puts t(:update)
  end

  desc "finalize"
  task :finalize do
    puts t(:finalize)
  end

  desc "restart"
  task :restart do
    puts t(:restart)
  end

  desc "finishing"
  task :finishing do
    puts t(:finishing)
  end

  desc "finished"
  task :finished do
    puts t(:finished)
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
