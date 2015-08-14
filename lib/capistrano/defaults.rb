validate :application do |_key, value|
  changed_value = value.gsub(/[^[[:alnum:]]]/, '_')
  if value != changed_value
    warn "Invalid value for :application detected! Try using this: "
    warn "  set :application, '#{changed_value}'"
    raise Capistrano::ValidationError
  end
end

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
