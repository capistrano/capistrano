set :scm, :git
set :branch, :master
set :deploy_to, "/var/www/#{fetch(:application)}"

set :default_environment, {}
set :keep_releases, 5

set :format, :pretty
set :log_level, :debug

set :pty, true
