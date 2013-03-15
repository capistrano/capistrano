namespace :git do

  desc 'Check that the repository exists'
  task :check do
    on all do
      unless test "[ -d #{repo_path} ]"
        within deploy_path do
          execute :git, :clone, fetch(:repo), repo_path
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
    on all do
      within repo_path do
        execute :git, 'fetch origin'
        execute :git,  "reset --hard origin/#{fetch(:branch)}"
      end
    end
  end

  desc 'Copy repo to releases'
  task :create_release do
    on all do
      execute :cp, "-RPp", repo_path, release_path
    end
  end
end
