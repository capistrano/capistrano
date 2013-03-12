namespace :deploy do

  desc 'Starting'
  task :starting do
  end

  desc 'Started'
  task :started do
  end

  desc 'Update'
  task :update do
  end

  desc 'Finalize'
  task :finalize do
  end

  desc 'Restart'
  task :restart do
  end

  desc 'Finishing'
  task :finishing do
  end

  desc 'Finished'
  task :finished do
  end

  before :starting, :ensure_stage do
    unless stage_set?
      puts t(:stage_not_set)
      exit 1
    end
  end
end

desc 'Deploy'
task :deploy do
  %w{starting started update finalize restart finishing finished}.each do |task|
    invoke "deploy:#{task}"
  end
end
task default: :deploy
