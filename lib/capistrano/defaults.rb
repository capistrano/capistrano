set_if_empty :scm, :git
set_if_empty :branch, :master
set_if_empty :deploy_to, -> { "/var/www/#{fetch(:application)}" }
set_if_empty :tmp_dir, "/tmp"

set_if_empty :default_env, {}
set_if_empty :keep_releases, 5

set_if_empty :format, :pretty
set_if_empty :log_level, :debug

set_if_empty :pty, false

set_if_empty :local_user, -> { Etc.getlogin }
