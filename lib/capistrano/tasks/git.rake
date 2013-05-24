namespace :git do

  git_environmental_variables = {
    git_askpass: '/bin/echo',
    git_ssh:     '/tmp/git-ssh.sh'
  }

  desc 'Upload the git wrapper script, this script guarantees that we can script git without getting an interactive prompt'
  task :wrapper do
    on roles :all do
      upload! StringIO.new("#!/bin/sh -e\nexec /usr/bin/ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no \"$@\"\n"), '/tmp/git-ssh.sh'
      execute :chmod, "+x", '/tmp/git-ssh.sh'
    end
  end

  desc 'Check that the repository is reachable'
  task check: :'git:wrapper' do
    fetch(:branch)
    on roles :all do
      with git_environmental_variables do
        execute :git, :'ls-remote', fetch(:repo)
      end
    end
  end

  desc 'Clone the repo to the cache'
  task clone: :'git:wrapper' do
    on roles :all do
      if test " [ -d #{repo_path}/.git ] "
        info "The repository mirror is at #{repo_path}"
      else
        within deploy_path do
          with git_environmental_variables do
            execute :git, :clone, '--mirror', fetch(:repo), repo_path
          end
        end
      end
    end
  end

  desc 'Update the repo mirror to reflect the origin state'
  task update: :'git:clone' do
    on roles :all do
      within repo_path do
        execute :git, :remote, :update
      end
    end
  end

  desc 'Copy repo to releases'
  task create_release: :'git:update' do
    on roles :all do
      with git_environmental_variables do
        execute :git, :remote, 'set-url', fetch(:repo)
        execute :git, :clone, '--branch', fetch(:branch),                     \
                '--single-branch',                                            \
                '--recurse-submodules',                                       \
                '--no-hardlinks',                                             \
                repo_path, release_path
      end
    end
  end
end

