namespace :deploy do

  desc 'Start a deployment, make sure server(s) ready.'
  task :starting do
  end

  desc 'Started'
  task :started do
  end

  desc 'Update server(s) by setting up a new release.'
  task :updating do
  end

  desc 'Updated'
  task :updated do
  end

  desc 'Revert server(s) to previous release.'
  task :reverting do
  end

  desc 'Reverted'
  task :reverted do
  end

  desc 'Publish the release.'
  task :publishing do
  end

  desc 'Published'
  task :published do
  end

  desc 'Finish the deployment, clean up server(s).'
  task :finishing do
  end

  desc 'Finish the rollback, clean up server(s).'
  task :finishing_rollback do
  end

  desc 'Finished'
  task :finished do
  end

  desc 'Deploy failed'
  task :failed do
  end

  desc 'Rollback to previous release.'
  task :rollback do
    begin
      %w{ starting started
          reverting reverted
          publishing published
          finishing_rollback finished }.each do |task|
        invoke "deploy:#{task}"
      end
    rescue
      invoke 'deploy:failed'
      raise
    end
  end
end

desc 'Deploy a new release.'
task :deploy do
  begin
    %w{ starting started
        updating updated
        publishing published
        finishing finished }.each do |task|
      invoke "deploy:#{task}"
    end
  rescue
    invoke 'deploy:failed'
    raise
  end
end
task default: :deploy
