namespace :hg do
  desc 'Check that the repo is reachable'
  task :check do
    on release_roles :all do
      scm_perform(&Capistrano::Hg.method(:check))
    end
  end

  desc 'Clone the repo to the cache'
  task :clone do
    on release_roles :all do
      if scm_perform(&Capistrano::Hg.method(:test))
        info t(:mirror_exists, at: repo_path)
      else
        within deploy_path do
          scm_perform(&Capistrano::Hg.method(:clone))
        end
      end
    end
  end

  desc 'Pull changes from the remote repo'
  task :update => :'hg:clone' do
    on release_roles :all do
      within repo_path do
        scm_perform(&Capistrano::Hg.method(:update))
      end
    end
  end

  desc 'Copy repo to releases'
  task :create_release => :'hg:update' do
    on release_roles :all do
      within repo_path do
        scm_perform(&Capistrano::Hg.method(:release))
      end
    end
  end
end
