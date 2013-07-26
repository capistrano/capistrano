set :scm, :git
set :branch, :master
set :deploy_to, "/var/www/#{fetch(:application)}"
set :tmp_dir, "/tmp"

set :default_env, {}
set :keep_releases, 5

set :format, :pretty
set :log_level, :debug

set :pty, true

namespace :deploy do
  task :ensure_stage do
    unless stage_set?
      puts t(:stage_not_set)
      exit 1
    end
  end
end
