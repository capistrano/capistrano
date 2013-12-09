namespace :git do
  def submodules?
    fetch(:git_enable_submodules, false) != false
  end

  def recursive?
    fetch(:git_submodules_recursive, false) != false
  end

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
        exit 1 unless test :git, :'ls-remote', repo_url
      end
    end
  end

  desc 'Clone the repo to the cache'
  task clone: :'git:wrapper' do
    on release_roles :all do
      test_file = submodules? ? "#{repo_path}/.git/HEAD" : "#{repo_path}/HEAD"
      if test " [ -f #{test_file} ] "
        info t(:mirror_exists, at: repo_path)

      else
        within deploy_path do
          with fetch(:git_environmental_variables) do
            git = [ :git, :clone, '--mirror', repo_url, repo_path ]

            if submodules?
              git.delete('--mirror')
              git.insert(2, '-b', fetch(:branch))
            end

            execute *git
          end
        end

        if submodules?
          within repo_path do
            with fetch(:git_environmental_variables) do
              git = [ :git, :submodule, :update, '--init' ]
              git << '--recursive' if recursive?

              execute *git
            end
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
          if submodules?
            execute :git, :pull

            git = [:git, :submodule, :update]
            git << '--recursive' if recursive?

            execute *git
          else
            execute :git, :remote, :update
          end
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

          if submodules?
            execute :tar, '--exclude=.git\*', '-cf', '-', '.', "| ( cd #{release_path}  && tar -xf - )"
          else
            execute :git, :archive, fetch(:branch), '| tar -x -C', release_path
          end
        end
      end
    end
  end
end

