namespace :deploy do

  task :starting do
    invoke 'deploy:check'
  end

  task :updating => :new_release_path do
    invoke "#{scm}:create_release"
    invoke 'deploy:symlink:shared'
  end

  task :reverting do
    invoke 'deploy:revert_release'
  end

  task :publishing do
    invoke 'deploy:symlink:release'
  end

  task :finishing do
    invoke 'deploy:cleanup'
  end

  task :finishing_rollback do
    invoke 'deploy:cleanup_rollback'
  end

  task :finished do
    invoke 'deploy:log_revision'
  end

  desc 'Check required files and directories exist'
  task :check do
    invoke "#{scm}:check"
    invoke 'deploy:check:directories'
    invoke 'deploy:check:linked_dirs'
    invoke 'deploy:check:make_linked_dirs'
    invoke 'deploy:check:linked_files'
  end

  namespace :check do
    desc 'Check shared and release directories exist'
    task :directories do
      on release_roles :all do
        execute :mkdir, '-pv', shared_path, releases_path
      end
    end

    desc 'Check directories to be linked exist in shared'
    task :linked_dirs do
      next unless any? :linked_dirs
      on release_roles :all do
        execute :mkdir, '-pv', linked_dirs(shared_path)
      end
    end

    desc 'Check directories of files to be linked exist in shared'
    task :make_linked_dirs do
      next unless any? :linked_files
      on release_roles :all do |host|
        execute :mkdir, '-pv', linked_file_dirs(shared_path)
      end
    end

    desc 'Check files to be linked exist in shared'
    task :linked_files do
      next unless any? :linked_files
      on release_roles :all do |host|
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
      on release_roles :all do
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
      on release_roles :all do
        execute :mkdir, '-pv', linked_dir_parents(release_path)

        fetch(:linked_dirs).each do |dir|
          target = release_path.join(dir)
          source = shared_path.join(dir)
          unless test "[ -L #{target} ]"
            if test "[ -d #{target} ]"
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
      on release_roles :all do
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
    on release_roles :all do |host|
      releases = capture(:ls, '-x', releases_path).split
      if releases.count >= fetch(:keep_releases)
        info t(:keeping_releases, host: host.to_s, keep_releases: fetch(:keep_releases), releases: releases.count)
        directories = (releases - releases.last(fetch(:keep_releases)))
        if directories.any?
          directories_str = directories.map do |release|
            releases_path.join(release)
          end.join(" ")
          execute :rm, '-rf', directories_str
        else
          info t(:no_old_releases, host: host.to_s, keep_releases: fetch(:keep_releases))
        end
      end
    end
  end

  desc 'Remove and archive rolled-back release.'
  task :cleanup_rollback do
    on release_roles(:all) do
      last_release = capture(:ls, '-xr', releases_path).split.first
      last_release_path = releases_path.join(last_release)
      if test "[ `readlink #{current_path}` != #{last_release_path} ]"
        execute :tar, '-czf',
          deploy_path.join("rolled-back-release-#{last_release}.tar.gz"),
        last_release_path
        execute :rm, '-rf', last_release_path
      else
        debug 'Last release is the current release, skip cleanup_rollback.'
      end
    end
  end

  desc 'Log details of the deploy'
  task :log_revision do
    on release_roles(:all) do
      within releases_path do
        execute %{echo "#{revision_log_message}" >> #{revision_log}}
      end
    end
  end

  desc 'Revert to previous release timestamp'
  task :revert_release => :rollback_release_path do
    on release_roles(:all) do
      set(:revision_log_message, rollback_log_message)
    end
  end

  task :new_release_path do
    set_release_path
  end

  task :last_release_path do
    on release_roles(:all) do
      last_release = capture(:ls, '-xr', releases_path).split[1]
      set_release_path(last_release)
    end
  end

  task :rollback_release_path do
    on release_roles(:all) do
      last_release = capture(:ls, '-xr', releases_path).split[1]
      set_release_path(last_release)
      set(:rollback_timestamp, last_release)
    end
  end

  task :restart
  task :failed

end
