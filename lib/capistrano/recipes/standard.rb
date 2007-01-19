# Standard tasks that are useful for most recipes. It makes a few assumptions:
# 
# * The :app role has been defined as the set of machines consisting of the
#   application servers.
# * The :web role has been defined as the set of machines consisting of the
#   web servers.
# * The :db role has been defined as the set of machines consisting of the
#   databases, with exactly one set up as the :primary DB server.
# * The Rails spawner and reaper scripts are being used to manage the FCGI
#   processes.

set :rake, "rake"

set :rails_env, :production

set :migrate_target, :current
set :migrate_env, ""

set :use_sudo, true
set(:run_method) { use_sudo ? :sudo : :run }

set :spinner_user, :app

desc "Enumerate and describe every available task."
task :show_tasks do
  puts "Available tasks"
  puts "---------------"
  each_task do |info|
    wrap_length = 80 - info[:longest] - 1
    lines = info[:desc].gsub(/(.{1,#{wrap_length}})(?:\s|\Z)+/, "\\1\n").split(/\n/)
    puts "%-#{info[:longest]}s %s" % [info[:task], lines.shift]
    puts "%#{info[:longest]}s %s" % ["", lines.shift] until lines.empty?
    puts
  end
end

desc "Set up the expected application directory structure on all boxes"
task :setup, :except => { :no_release => true } do
  run <<-CMD
    umask 02 &&
    mkdir -p #{deploy_to} #{releases_path} #{shared_path} #{shared_path}/system &&
    mkdir -p #{shared_path}/log &&
    mkdir -p #{shared_path}/pids
  CMD
end

desc <<-DESC
Disable the web server by writing a "maintenance.html" file to the web
servers. The servers must be configured to detect the presence of this file,
and if it is present, always display it instead of performing the request.
DESC
task :disable_web, :roles => :web do
  on_rollback { delete "#{shared_path}/system/maintenance.html" }

  maintenance = render("maintenance", :deadline => ENV['UNTIL'],
    :reason => ENV['REASON'])
  put maintenance, "#{shared_path}/system/maintenance.html", :mode => 0644
end

desc %(Re-enable the web server by deleting any "maintenance.html" file.)
task :enable_web, :roles => :web do
  delete "#{shared_path}/system/maintenance.html"
end

desc <<-DESC
Update all servers with the latest release of the source code. All this does
is do a checkout (as defined by the selected scm module).
DESC
task :update_code, :except => { :no_release => true } do
  on_rollback { delete release_path, :recursive => true }

  source.checkout(self)

  run "chmod -R g+w #{release_path}"

  run <<-CMD
    rm -rf #{release_path}/log #{release_path}/public/system &&
    ln -nfs #{shared_path}/log #{release_path}/log &&
    ln -nfs #{shared_path}/system #{release_path}/public/system
  CMD
  
  run <<-CMD
    test -d #{shared_path}/pids && 
    rm -rf #{release_path}/tmp/pids && 
    ln -nfs #{shared_path}/pids #{release_path}/tmp/pids; true
  CMD

  # update the asset timestamps so they are in sync across all servers. This
  # lets the asset timestamping feature of rails work correctly
  stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
  asset_paths = %w(images stylesheets javascripts).map { |p| "#{release_path}/public/#{p}" }
  run "TZ=UTC find #{asset_paths.join(" ")} -exec touch -t #{stamp} {} \\;; true"

  # uncache the list of releases, so that the next time it is called it will
  # include the newly released path.
  @releases = nil
end

desc <<-DESC
Rollback the latest checked-out version to the previous one by fixing the
symlinks and deleting the current release from all servers.
DESC
task :rollback_code, :except => { :no_release => true } do
  if releases.length < 2
    raise "could not rollback the code because there is no prior release"
  else
    run <<-CMD
      ln -nfs #{previous_release} #{current_path} &&
      rm -rf #{current_release}
    CMD
  end
end

desc <<-DESC
Update the 'current' symlink to point to the latest version of
the application's code.
DESC
task :symlink, :except => { :no_release => true } do
  on_rollback { run "ln -nfs #{previous_release} #{current_path}" }
  run "ln -nfs #{current_release} #{current_path}"
end

desc <<-DESC
Restart the FCGI processes on the app server. This uses the :use_sudo
variable to determine whether to use sudo or not. By default, :use_sudo is
set to true, but you can set it to false if you are in a shared environment.
DESC
task :restart, :roles => :app do
  send(run_method, "#{current_path}/script/process/reaper")
end

desc <<-DESC
Updates the code and fixes the symlink under a transaction
DESC
task :update do
  transaction do
    update_code
    symlink
  end
end

desc <<-DESC
Run the migrate rake task. By default, it runs this in the version of the app
indicated by the 'current' symlink. (This means you should not invoke this task
until the symlink has been updated to the most recent version.) However, you
can specify a different release via the migrate_target variable, which must be
one of "current" (for the default behavior), or "latest" (for the latest release
to be deployed with the update_code task). You can also specify additional
environment variables to pass to rake via the migrate_env variable. Finally, you
can specify the full path to the rake executable by setting the rake variable.
DESC
task :migrate, :roles => :db, :only => { :primary => true } do
  directory = case migrate_target.to_sym
    when :current then current_path
    when :latest  then current_release
    else
      raise ArgumentError,
        "you must specify one of current or latest for migrate_target"
  end

  run "cd #{directory} && " +
      "#{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:migrate"
end

desc <<-DESC
A macro-task that updates the code, fixes the symlink, and restarts the
application servers.
DESC
task :deploy do
  update
  restart
end

desc <<-DESC
Similar to deploy, but it runs the migrate task on the new release before
updating the symlink. (Note that the update in this case it is not atomic,
and transactions are not used, because migrations are not guaranteed to be
reversible.)
DESC
task :deploy_with_migrations do
  update_code

  begin
    old_migrate_target = migrate_target
    set :migrate_target, :latest
    migrate
  ensure
    set :migrate_target, old_migrate_target
  end

  symlink

  restart
end

desc "A macro-task that rolls back the code and restarts the application servers."
task :rollback do
  rollback_code
  restart
end

desc <<-DESC
Displays the diff between HEAD and what was last deployed. (Not available
with all SCM's.)
DESC
task :diff_from_last_deploy do
  diff = source.diff(self)
  puts
  puts diff
  puts
end

desc "Update the currently released version of the software directly via an SCM update operation"
task :update_current do
  source.update(self)
end

desc <<-DESC
Removes unused releases from the releases directory. By default, the last 5
releases are retained, but this can be configured with the 'keep_releases'
variable. This will use sudo to do the delete by default, but you can specify
that run should be used by setting the :use_sudo variable to false.
DESC
task :cleanup, :except => { :no_release => true } do
  count = (self[:keep_releases] || 5).to_i
  if count >= releases.length
    logger.important "no old releases to clean up"
  else
    logger.info "keeping #{count} of #{releases.length} deployed releases"
    directories = (releases - releases.last(count)).map { |release|
      File.join(releases_path, release) }.join(" ")

    send(run_method, "rm -rf #{directories}")
  end
end

desc <<-DESC
Start the spinner daemon for the application (requires script/spin). This will
use sudo to start the spinner by default, unless :use_sudo is false. If using
sudo, you can specify the user that the spinner ought to run as by setting the
:spinner_user variable (defaults to :app).
DESC
task :spinner, :roles => :app do
  user = (use_sudo && spinner_user) ? "-u #{spinner_user} " : ""
  send(run_method, "#{user}#{current_path}/script/spin")
end

desc <<-DESC
Used only for deploying when the spinner isn't running. It invokes 'update',
and when it finishes it then invokes the spinner task (to start the spinner).
DESC
task :cold_deploy do
  update
  spinner
end

desc <<-DESC
A simple task for performing one-off commands that may not require a full task
to be written for them. Simply specify the command to execute via the COMMAND
environment variable. To execute the command only on certain roles, specify
the ROLES environment variable as a comma-delimited list of role names. Lastly,
if you want to execute the command via sudo, specify a non-empty value for the
SUDO environment variable.
DESC
task :invoke, :roles => Capistrano.str2roles(ENV["ROLES"] || "") do
  method = ENV["SUDO"] ? :sudo : :run
  send(method, ENV["COMMAND"])
end

desc <<-DESC
Begin an interactive Capistrano session. This gives you an interactive
terminal from which to execute tasks and commands on all of your servers.
(This is still an experimental feature, and is subject to change without
notice!)
DESC
task(:shell) do
  require 'capistrano/shell'
  Capistrano::Shell.run!(self)
end
