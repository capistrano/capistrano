namespace :deploy do
  task :started do
    invoke 'deploy:ensure:directories'
    invoke "#{scm}:prepare"
  end

  task :update do
    invoke "#{scm}:update"
    invoke 'deploy:symlink:shared'
  end

  task :finalize do
    invoke 'deploy:symlink:release'
    invoke 'deploy:normalise_assets'
  end

  after :restart, 'deploy:web:ensure'

  task :finishing do
    invoke 'deploy:cleanup'
  end

  task :finished do
    invoke 'deploy:log_revision'
  end

  namespace :check do

  end

  namespace :ensure do
    task :directories do
      on all do
        unless test "[ -d #{shared_path} ]"
          execute :mkdir, '-p', shared_path
        end

        unless test "[ -d #{releases_path} ]"
          execute :mkdir, '-p', releases_path
        end
      end
    end
  end

  namespace :symlink do
    task :release do
      on all do
        execute :rm, '-rf', current_path
        execute :ln, '-s', release_path, current_path
      end
    end

    task :shared do
      # configuration exists
      on all do
        fetch(:linked_files).each do |file|
          unless test "[ -f #{shared_path}/#{file} ]"
            # create config file
          end
        end
      end

      # configuration is symlinked
      on all do
        fetch(:linked_files).each do |file|
          target = File.join(release_path, file)
          source = File.join(shared_path, file)
          unless test "[ -L #{target} ]"
            if test "[ -f #{target} ]"
              execute :rm, target
            end
            execute :ln, '-s', source, target
          end
        end
      end

      # tmp/log/public folders exist in shared
      on all do
        fetch(:linked_dirs).each do |dir|
          dir = File.join(shared_path, dir)
          unless test "[ -d #{dir} ]"
            execute :mkdir, '-p', dir
          end
        end
      end

      # tmp/log/public folders are symlinked
      on all do
        fetch(:linked_dirs).each do |dir|
          target = File.join(release_path, dir)
          source = File.join(shared_path, dir)
          unless test "[ -L #{target} ]"
            if test "[ -f #{target} ]"
              execute :rm, '-rf', target
            end
            execute :ln, '-s', source, target
          end
        end
      end
    end
  end

  namespace :web do
    task :ensure do
      on roles(:web) do
        within shared_path do
          file = File.join(shared_path, maintenance_page)
          if test "[ -f #{shared_path}/#{file} ]"
            execute :rm, file
          end
        end
      end
    end
  end

  task :disable do
    on all do
      within shared_path do
        execute :touch, maintenance_page
      end
    end
  end

  task :normalise_assets do
    on roles(:web) do
      within release_path do
        assets = %{public/images public/javascripts public/stylesheets}
        execute :find, "#{assets} -exec touch -t #{asset_timestamp} {} ';'; true"
      end
    end
  end

  task :cleanup do
    on all do
      count = fetch(:keep_releases, 5).to_i
      releases = capture("ls -xt #{releases_path}").split.reverse
      if releases.length >= count
        info "keeping #{count} of #{releases.length} deployed releases"
        directories = (releases - releases.last(count)).map { |release|
          File.join(releases_path, release) }.join(" ")
        execute :rm, '-rf', directories
      end
    end
  end

  task :log_revision do
    on roles(:web) do
      within releases_path do
        execute %{echo "#{revision_log_message}" >> #{revision_log}}
      end
    end
  end
end
