# A collection of compatibility scripts, to ease the transition between
# Capistrano 1.x and Capistrano 2.x.

# Depends on the deployment system
load 'deploy'

desc "DEPRECATED: See deploy:pending:diff."
task :diff_from_last_deploy do
  warn "[DEPRECATION] `diff_from_last_deploy' is deprecated. Use `deploy:pending:diff' instead."
  deploy.pending.diff
end

desc "DEPRECATED: See deploy:update."
task :update do
  warn "[DEPRECATION] `update' is deprecated. Use `deploy:update' instead."
  deploy.update
end

desc "DEPRECATED: See deploy:update_code."
task :update_code do
  warn "[DEPRECATION] `update_code' is deprecated. Use `deploy:update_code' instead."
  deploy.update_code
end

desc "DEPRECATED: See deploy:symlink."
task :symlink do
  warn "[DEPRECATION] `symlink' is deprecated. Use `deploy:symlink' instead."
  deploy.symlink
end

desc "DEPRECATED: See deploy:restart."
task :restart do
  warn "[DEPRECATION] `restart' is deprecated. Use `deploy:restart' instead."
  deploy.restart
end

desc "DEPRECATED: See deploy:rollback."
task :rollback do
  warn "[DEPRECATION] `rollback' is deprecated. Use `deploy:rollback' instead."
  deploy.rollback
end
