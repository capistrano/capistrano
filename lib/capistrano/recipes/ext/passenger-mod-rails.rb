namespace :deploy do 
  
  desc <<-DESC
    Restarts your application. This works by touching the tmp/restart.txt file
    
    By default, this will be invoked via sudo. You can run this as the deployment
    user by setting:
    
      set :use_sudo, false
  DESC
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{current_path}/tmp/restart.txt"
  end
  
end

after('deploy:update', 'deploy:restart')
after('deploy:rollback', 'deploy:restart')
after('deploy:migrations', 'deploy:restart')