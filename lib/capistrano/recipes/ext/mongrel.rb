namespace :deploy

  desc <<-DESC
    Restarts your application. This works by calling the script/process/reaper \
    script under the current path.
  
    By default, this will be invoked via sudo as the `app' user. If \
    you wish to run it as a different user, set the :runner variable to \
    that user. If you are in an environment where you can't use sudo, set \
    the :use_sudo variable to false:
  
      set :use_sudo, false
  DESC
  task :restart, :roles => :app, :except => { :no_release => true } do
    try_runner "#{current_path}/script/process/reaper"
  end

  desc <<-DESC
    Start the application servers. This will attempt to invoke a script \
    in your application called `script/spin', which must know how to start \
    your application listeners. For Rails applications, you might just have \
    that script invoke `script/process/spawner' with the appropriate \
    arguments.

    By default, the script will be executed via sudo as the `app' user. If \
    you wish to run it as a different user, set the :runner variable to \
    that user. If you are in an environment where you can't use sudo, set \
    the :use_sudo variable to false.
  DESC
  task :start, :roles => :app do
    run "cd #{current_path} && #{try_runner} nohup script/spin"
  end

  desc <<-DESC
    Stop the application servers. This will call script/process/reaper for \
    both the spawner process, and all of the application processes it has \
    spawned. As such, it is fairly Rails specific and may need to be \
    overridden for other systems.

    By default, the script will be executed via sudo as the `app' user. If \
    you wish to run it as a different user, set the :runner variable to \
    that user. If you are in an environment where you can't use sudo, set \
    the :use_sudo variable to false.
  DESC
  task :stop, :roles => :app do
    run "if [ -f #{current_path}/tmp/pids/dispatch.spawner.pid ]; then #{try_runner} #{current_path}/script/process/reaper -a kill -r dispatch.spawner.pid; fi"
    try_runner "#{current_path}/script/process/reaper -a kill"
  end
  
end

after('deploy:cold',       'deploy:start')
after('deploy:update',     'deploy:restart')
after('deploy:rollback',   'deploy:restart')
after('deploy:migrations', 'deploy:restart')