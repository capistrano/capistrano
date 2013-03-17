namespace :deploy do

  task :started do
    invoke 'deploy:check'
  end

  task :update do
    invoke "#{scm}:update"
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
      on roles :app do
        fetch(:linked_dirs).each do |dir|
          dir = shared_path.join(dir)
          execute :mkdir, '-pv', dir
        end
      end
    end

    desc 'Check files to be linked exist in shared'
    task :linked_files do
      on roles :app do |host|
        fetch(:linked_files).each do |file|
          file_path = shared_path.join(file)
          parent = file_path.dirname
          execute :mkdir, '-pv', parent
          unless test "[ -f #{file_path} ]"
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
      on roles :app do
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
      on roles :app do
        fetch(:linked_dirs).each do |dir|
          target = release_path.join(dir)
          source = shared_path.join(dir)
          parent = target.dirname
          execute :mkdir, '-pv', parent
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
      on roles :app do
        fetch(:linked_files).each do |file|
          target = release_path.join(file)
          source = shared_path.join(file)
          parent = target.dirname
          execute :mkdir, '-pv', parent
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
    on roles :all do
      release = capture(:ls, '-xt', releases_path).split.reverse
      if releases.count >= keep_releases
        info t(:keeping_releases, keep_releases: keep_releases, releases: releases.count)
        directories = (releases - releases.last(keep_releases)).map { |release|
          releases_path.join(release) }.join(" ")
        execute :rm, '-rf', directories
      end
    end
  end

  desc 'Log details of the deploy'
  task :log_revision do
    on roles :app do
      within releases_path do
        execute %{echo "#{revision_log_message}" >> #{revision_log}}
      end
    end
  end
end
