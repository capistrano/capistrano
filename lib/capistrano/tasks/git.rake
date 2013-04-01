namespace :git do

  desc 'Check that the repository exists'
  task :check do
    fetch(:branch)
    on roles :all do
      unless test "[ -d #{repo_path}/.git ]"
        within deploy_path do
          upload! StringIO.new("#!/bin/sh -e\nexec /usr/bin/ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no \"$@\"\n"), '/tmp/git-ssh.sh'
          execute :chmod, "+x", '/tmp/git-ssh.sh'
          with git_askpass: '/bin/echo', git_ssh: '/tmp/git-ssh.sh' do
            execute :git, :clone, fetch(:repo), repo_path
          end
        end
      end
    end
  end

  desc 'Update the repo and copy to releases'
  task :update do
    invoke 'git:reset'
    invoke 'git:create_release'
  end

  desc 'Update the repo to branch or reference provided provided'
  task :reset do
    on roles :all do
      within repo_path do
        execute :git, 'fetch origin'
        execute :git,  "reset --hard origin/#{fetch(:branch)}"
      end
    end
  end

  desc 'Copy repo to releases'
  task :create_release do
    on roles :all do
      execute :cp, "-RPp", repo_path, release_path
    end
  end
end

