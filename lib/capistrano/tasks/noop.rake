namespace :noop do

  def strategy
    @strategy ||= Capistrano::Noop.new(self, fetch(:noop_strategy, Capistrano::Noop::DefaultStrategy))
  end

  desc 'Check that the repository is reachable'
  task :check do
    on release_roles :all do
      exit 1 unless strategy.check
    end
  end

  desc 'Clone the repo to the cache'
  task :clone do
  end

  desc 'Update the repo mirror to reflect the origin state'
  task :update do
  end

  desc 'Copy repo to releases'
  task :create_release do
    on release_roles :all do
      within repo_path do
        execute :ln, '-s', repo_path, release_path
      end
    end
  end
end

