include Capistrano::DSL

SSHKit.configure do |sshkit|
  sshkit.format = env.format
end

namespace :deploy do

  desc "starting"
  task :starting do
    puts 'starting'
  end

  desc "start"
  task :start do
    puts 'start'
  end

  desc "update"
  task :update do
    puts 'update'
  end

  desc "finalize"
  task :finalize do
    puts 'finalize'
  end

  desc "restart"
  task :restart do
    puts 'restart'
  end

  desc "finishing"
  task :finishing do
    puts 'finishing'
  end

  desc "finished"
  task :finished do
    puts 'finished'
  end
end

desc "Deploy"
task :deploy do
  %w{starting start update finalize restart finishing finished}.each do |stage|
    invoke stage
  end
end
task default: :deploy

