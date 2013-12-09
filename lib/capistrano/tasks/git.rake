namespace :git do

  set :git_environmental_variables, ->() {
    {
      git_askpass: "/bin/echo",
      git_ssh:     "#{fetch(:tmp_dir)}/#{fetch(:application)}/git-ssh.sh"
    }
  }

  desc 'Upload the git wrapper script, this script guarantees that we can script git without getting an interactive prompt'
  task :wrapper do
    on release_roles :all do
      execute :mkdir, "-p", "#{fetch(:tmp_dir)}/#{fetch(:application)}/"
      upload! StringIO.new("#!/bin/sh -e\nexec /usr/bin/ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no \"$@\"\n"), "#{fetch(:tmp_dir)}/#{fetch(:application)}/git-ssh.sh"
      execute :chmod, "+x", "#{fetch(:tmp_dir)}/#{fetch(:application)}/git-ssh.sh"
    end
  end

  desc 'Check that the repository is reachable'
  task check: :'git:wrapper' do
    fetch(:branch)
    on release_roles :all do
      with fetch(:git_environmental_variables) do
        scm_perform(&Capistrano::Git.method(:check))
      end
    end
  end

  desc 'Clone the repo to the cache'
  task clone: :'git:wrapper' do
    on release_roles :all do
      if scm_perform(&Capistrano::Git.test)
        info t(:mirror_exists, at: repo_path)
      else
        within deploy_path do
          with fetch(:git_environmental_variables) do
            scm_perform(&Capistrano::Git.method(:clone))
          end
        end
      end
    end
  end

  desc 'Update the repo mirror to reflect the origin state'
  task update: :'git:clone' do
    on release_roles :all do
      within repo_path do
        capturing_revisions do
          scm_perform(&Capistrano::Git.method(:update))
        end
      end
    end
  end

  desc 'Copy repo to releases'
  task create_release: :'git:update' do
    on release_roles :all do
      with fetch(:git_environmental_variables) do
        within repo_path do
          execute :mkdir, '-p', release_path
          scm_perform(&Capistrano::Git.method(:release))
        end
      end
    end
  end
end

