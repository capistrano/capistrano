namespace :deploy do

  task :started do
    invoke 'deploy:check'
  end

  task :update do
    invoke "#{scm}:create_release"
    invoke 'deploy:symlink:shared'
  end

  task :finalize do
    invoke 'deploy:symlink:release'
  end

  task :finished do
    invoke 'deploy:log_revision'
  end

  desc 'Check required files and directories exist'
  task :check do
    invoke "#{scm}:check"
    invoke 'deploy:check:directories'
    invoke 'deploy:check:linked_dirs'
    invoke 'deploy:check:linked_files'
  end

  namespace :check do
    desc 'Check shared and release directories exist'
    task :directories do
      on roles :all do
        execute :mkdir, '-pv', shared_path, releases_path
      end
    end

    desc 'Check directories to be linked exist in shared'
    task :linked_dirs do
      next unless any? :linked_dirs
      on roles :app do
        execute :mkdir, '-pv', linked_dirs(shared_path)
      end
    end

    desc 'Check files to be linked exist in shared'
    task :linked_files do
      next unless any? :linked_files
      on roles :app do |host|
        execute :mkdir, '-pv', linked_file_dirs(shared_path)
        linked_files(shared_path).each do |file|
          unless test "[ -f #{file} ]"
            error t(:linked_file_does_not_exist, file: file, host: host)
            exit 1
          end
        end
      end
    end
  end

  namespace :symlink do
    desc 'Symlink release to current'
    task :release do
      on roles :web, :app do
        execute :rm, '-rf', current_path
        execute :ln, '-s', release_path, current_path
      end
    end

    desc 'Symlink files and directories from shared to release'
    task :shared do
      invoke 'deploy:symlink:linked_files'
      invoke 'deploy:symlink:linked_dirs'
    end

    desc 'Symlink linked directories'
    task :linked_dirs do
      next unless any? :linked_dirs
      on roles :app do
        execute :mkdir, '-pv', linked_dir_parents(release_path)

        fetch(:linked_dirs).each do |dir|
          target = release_path.join(dir)
          source = shared_path.join(dir)
          unless test "[ -L #{target} ]"
            if test "[ -f #{target} ]"
              execute :rm, '-rf', target
            end
            execute :ln, '-s', source, target
          end
        end
      end
    end

    desc 'Symlink linked files'
    task :linked_files do
      next unless any? :linked_files
      on roles :app do
        execute :mkdir, '-pv', linked_file_dirs(release_path)

        fetch(:linked_files).each do |file|
          target = release_path.join(file)
          source = shared_path.join(file)
          unless test "[ -L #{target} ]"
            if test "[ -f #{target} ]"
              execute :rm, target
            end
            execute :ln, '-s', source, target
          end
        end
      end
    end
  end

  desc 'Clean up old releases'
  task :cleanup do
    on roles :all do |host|
      releases = capture(:ls, '-xt', releases_path).split.reverse
      if releases.count >= fetch(:keep_releases)
        info t(:keeping_releases, host: host.to_s, keep_releases: fetch(:keep_releases), releases: releases.count)
        directories = (releases - releases.last(fetch(:keep_releases))).map { |release|
          releases_path.join(release) }.join(" ")
        execute :rm, '-rf', directories
      end
    end
  end

  desc 'Log details of the deploy'
  task :log_revision do
    on primary :app do
      within releases_path do
        execute %{echo "#{revision_log_message}" >> #{revision_log}}
      end
    end
  end

  desc 'Rollback to the last release'
  task :rollback do
    on primary :app do
      last_release = capture(:ls, '-xt', releases_path).split[1]
      set(:rollback_release_timestamp, last_release)
      set(:branch, last_release)
      set(:revision_log_message, rollback_log_message)
    end

    on roles :app do
      %w{check finalize restart finishing finished}.each do |task|
        invoke "deploy:#{task}"
      end
    end
  end
end
