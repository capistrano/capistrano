namespace :hg do
  def strategy
    @strategy ||= Capistrano::Hg.new(self, fetch(:hg_strategy, Capistrano::Hg::DefaultStrategy))
  end

  desc "Check that the repo is reachable"
  task :check do
    on release_roles :all do
      strategy.check
    end
  end

  desc "Clone the repo to the cache"
  task :clone do
    on release_roles :all do
      if strategy.test
        info t(:mirror_exists, at: repo_path)
      else
        within deploy_path do
          strategy.clone
        end
      end
    end
  end

  desc "Pull changes from the remote repo"
  task update: :'hg:clone' do
    on release_roles :all do
      within repo_path do
        strategy.update
      end
    end
  end

  desc "Copy repo to releases"
  task create_release: :'hg:update' do
    on release_roles :all do
      within repo_path do
        strategy.release
      end
    end
  end

  desc "Determine the revision that will be deployed"
  task :set_current_revision do
    on release_roles :all do
      within repo_path do
        set :current_revision, strategy.fetch_revision
      end
    end
  end
end
