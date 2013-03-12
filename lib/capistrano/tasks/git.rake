namespace :git do
  task :prepare do
    on all do
      unless test "[ -d #{repo_path} ]"
        within deploy_path do
          as deploy_user do
            execute :git, :clone, fetch(:repo), repo_path
          end
        end
      end
    end
  end

  task :update do
    invoke 'git:reset_to_ref'
    invoke 'git:create_release'
  end

  task :reset_to_ref do
    on all do
      as deploy_user do
        within repo_path do
          execute :git, 'fetch origin'
          execute :git,  "reset --hard origin/#{fetch(:branch)}"
        end
      end
    end
  end

  task :create_release do
    on all do
      as deploy_user do
        execute :cp, "-RPp", repo_path, release_path
      end
    end
  end
end
