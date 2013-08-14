namespace :hg do
  desc 'Check that the repo is reachable'
  task :check do
    on roles :all do
      execute "hg", "id", repo_url
    end
  end

  desc 'Clone the repo to the cache'
  task :clone do
    on roles :all do
      if test " [ -d #{repo_path}/.hg ] "
        info t(:mirror_exists, at: repo_path)
      else
        within deploy_path do
          execute "hg", "clone", "--noupdate", repo_url, repo_path
        end
      end
    end
  end

  desc 'Pull changes from the remote repo'
  task :update => :'hg:clone' do
    on roles :all do
      within repo_path do
        execute "hg", "pull"
      end
    end
  end

  desc 'Copy repo to releases'
  task :create_release => :'hg:update' do
    on roles :all do
      within repo_path do
        execute "hg", "archive", release_path, "--rev", fetch(:branch)
      end
    end
  end
end
