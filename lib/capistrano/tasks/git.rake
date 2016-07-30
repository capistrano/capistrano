namespace :git do
  def strategy
    @strategy ||= Capistrano::Git.new(self, fetch(:git_strategy, Capistrano::Git::DefaultStrategy))
  end

  set :git_wrapper_path, lambda {
    # Try to avoid permissions issues when multiple users deploy the same app
    # by using different file names in the same dir for each deployer and stage.
    suffix = [:application, :stage, :local_user].map { |key| fetch(key).to_s }.join("-").gsub(/\s+/, "-")
    "#{fetch(:tmp_dir)}/git-ssh-#{suffix}.sh"
  }

  set :git_environmental_variables, lambda {
    {
      git_askpass: "/bin/echo",
      git_ssh: fetch(:git_wrapper_path)
    }
  }

  desc "Upload the git wrapper script, this script guarantees that we can script git without getting an interactive prompt"
  task :wrapper do
    on release_roles :all do
      execute :mkdir, "-p", File.dirname(fetch(:git_wrapper_path))
      upload! StringIO.new("#!/bin/sh -e\nexec /usr/bin/ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no \"$@\"\n"), fetch(:git_wrapper_path)
      execute :chmod, "700", fetch(:git_wrapper_path)
    end
  end

  desc "Check that the repository is reachable"
  task check: :'git:wrapper' do
    fetch(:branch)
    on release_roles :all do
      with fetch(:git_environmental_variables) do
        strategy.check
      end
    end
  end

  desc "Clone the repo to the cache"
  task clone: :'git:wrapper' do
    on release_roles :all do
      if strategy.test
        info t(:mirror_exists, at: repo_path)
      else
        within deploy_path do
          with fetch(:git_environmental_variables) do
            strategy.clone
          end
        end
      end
    end
  end

  desc "Update the repo mirror to reflect the origin state"
  task update: :'git:clone' do
    on release_roles :all do
      within repo_path do
        with fetch(:git_environmental_variables) do
          strategy.update
        end
      end
    end
  end

  desc "Copy repo to releases"
  task create_release: :'git:update' do
    on release_roles :all do
      with fetch(:git_environmental_variables) do
        within repo_path do
          execute :mkdir, "-p", release_path
          strategy.release
        end
      end
    end
  end

  desc "Determine the revision that will be deployed"
  task :set_current_revision do
    on release_roles :all do
      within repo_path do
        with fetch(:git_environmental_variables) do
          set :current_revision, strategy.fetch_revision
        end
      end
    end
  end
end
