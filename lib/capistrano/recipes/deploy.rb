require 'yaml'
require 'capistrano/recipes/deploy/scm'
require 'capistrano/recipes/deploy/strategy'

# =========================================================================
# These variables MUST be set in the client capfiles. If they are not set,
# the deploy will fail with an error.
# =========================================================================

set(:application) { abort "Please specify the name of your application, set :application, 'foo'" }
set(:repository)  { abort "Please specify the repository that houses your application's code, set :repository, 'foo'" }

# =========================================================================
# These variables may be set in the client capfile if their default values
# are not sufficient.
# =========================================================================

set :scm, :subversion
set :deploy_via, :checkout

set :restart_via, :sudo
set :group_writable, true

set(:deploy_to) { "/u/apps/#{application}" }
set(:revision)  { source.head } unless exists?(:revision)

# =========================================================================
# These variables should NOT be changed unless you are very confident in
# what you are doing. Make sure you understand all the implications of your
# changes if you do decide to muck with these!
# =========================================================================

set(:source)            { Capistrano::Deploy::SCM.new(scm, self) }
set(:real_revision)     { source.query_revision(revision) { |cmd| `#{cmd}` } }

set(:strategy)          { Capistrano::Deploy::Strategy.new(deploy_via, self) }

set(:release_name)      { Time.now.utc.strftime("%Y%m%d%H%M%S") }
set(:releases_path)     { File.join(deploy_to, "releases") }
set(:shared_path)       { File.join(deploy_to, "shared") }
set(:current_path)      { File.join(deploy_to, "current") }
set(:release_path)      { File.join(releases_path, release_name) }

set(:releases)          { capture("ls -x #{releases_path}").split.sort }
set(:current_release)   { File.join(releases_path, releases.last) }
set(:previous_release)  { File.join(releases_path, releases[-2]) }

set(:current_revision)  { capture("cat #{current_path}/REVISION").chomp }
set(:latest_revision)   { capture("cat #{current_release}/REVISION").chomp }
set(:previous_revision) { capture("cat #{previous_release}/REVISION").chomp }

namespace :deploy do
desc "Deploys your project. This calls both `update' and `restart'. Note that \
this will generally only work for applications that have already been deployed \
once. For a \"cold\" deploy, you'll want to take a look at the `cold_deploy' \
task, which handles the cold start specifically."
  task :default do
    update
    restart
  end

desc "Prepares one or more servers for deployment. Before you can use any \
of the Capistrano deployment tasks with your project, you will need to make \
sure all of your servers have been prepared with `cap setup'. When you add a \
new server to your cluster, you can easily run the setup task on just that \
server by specifying the HOSTS environment variable:

  $ cap HOSTS=new.server.com setup

It is safe to run this task on servers that have already been set up; it will \
not destroy any deployed revisions or data."
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, releases_path, shared_path]
    dirs += %w(system log pids).map { |d| File.join(shared_path, d) }
    run "umask 02 && mkdir -p #{dirs.join(' ')}"
  end

desc "Copies your project and updates the symlink. It does this in a transaction, \
so that if either `update_code' or `symlink' fail, all changes made to the \
remote servers will be rolled back, leaving your system in the same state it \
was in before `update' was invoked. Usually, you will want to call `deploy' \
instead of `update', but `update' can be handy if you want to deploy, but not \
immediately restart your application."
  task :update do
    transaction do
      update_code
      symlink
    end
  end

desc "Copies your project to the remote servers. This is the first stage \
of any deployment; moving your updated code and assets to the deployment \
servers. You will rarely call this task directly, however; instead, you should \
call the `deploy' task (to do a complete deploy) or the `update' task (if you \
want to perform the `restart' task separately).

You will need to make sure you set the :scm variable to the source control \
software you are using (it defaults to :subversion), and the :deploy_via \
variable to the strategy you want to use to deploy (it defaults to :checkout)."
  task :update_code, :except => { :no_release => true } do
    on_rollback { run "rm -rf #{release_path}; true" }
    strategy.deploy!
    finalize_update
  end

desc "[internal] Touches up the released code. This is called by update_code \
after the basic deploy finishes. It assumes a Rails project was deployed, so \
if you are deploying something else, you may want to override this task with \
your own environment's requirements.

This task will make the release group-writable (if the :group_writable \
variable is set to true, which is the default). It will then set up symlinks \
to the shared directory for the log, system, and tmp/pids directories, and \
will lastly touch all assets in public/images, public/stylesheets, and \
public/javascripts so that the times are consistent (so that asset timestamping \
works)."
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{release_path}" if group_writable

    run <<-CMD
      rm -rf #{release_path}/log #{release_path}/public/system #{release_path}/tmp/pids &&
      ln -s #{shared_path}/log #{release_path}/log &&
      ln -s #{shared_path}/system #{release_path}/public/system &&
      ln -s #{shared_path}pids #{release_path}/tmp/pids
    CMD

    stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
    asset_paths = %w(images stylesheets javascripts).map { |p| "#{release_path}/public/#{p}" }.join(" ")
    run "find #{asset_paths} -exec touch -t #{stamp} {} \\;; true", :env => { "TZ" => "UTC" }
  end

desc "Updates the symlink to the deployed version. Capistrano works by putting \
each new release of your application in its own directory. When you deploy a \
new version, this task's job is to update the `current' symlink to point at \
the new version. You will rarely need to call this task directly; instead, use \
the `deploy' task (which performs a complete deploy, including `restart') or \
the 'update' task (which does everything except `restart')."
  task :symlink, :except => { :no_release => true } do
    on_rollback { run "rm -f #{current_path}; ln -s #{previous_release} #{current_path}; true" }
    run "rm -f #{current_path} && ln -s #{release_path} #{current_path}"
  end

desc "Copy files to the currently deployed version. This is useful for updating \
files piecemeal, such as when you need to quickly deploy only a single file. \
Some files, such as updated templates, images, or stylesheets, might not require \
a full deploy, and especially in emergency situations it can be handy to just \
push the updates to production, quickly.

To use this task, specify the files and directories you want to copy as a \
comma-delimited list in the FILES environment variable. All directories will \
be processed recursively, with all files being pushed to the deployment \
servers. Any file or directory starting with a '.' character will be ignored.

  $ cap deploy:update_files FILES=templates,controller.rb"
  task :update_files, :except => { :no_release => true } do
    files = (ENV["FILES"] || "").
      split(",").
      map { |f| f.strip!; File.directory?(f) ? Dir["#{f}/**/*"] : f }.
      flatten.
      reject { |f| File.directory?(f) || File.basename(f)[0] == ?. }

    abort "Please specify at least one file to update (via the FILES environment variable)" if files.empty?

    files.each do |file|
      put File.read(file), File.join(current_path, file)
    end
  end

desc "Restarts your application. This works by calling the script/process/reaper \
script under the current path. By default, this will be invoked via sudo, but \
if you are in an environment where sudo is not an option, or is not allowed, \
you can indicate that restarts should use `run' instead by setting the \
`restart_via' variable:

  set :restart_via, :run"
  task :restart, :roles => :app, :except => { :no_release => true } do
    invoke_command "#{current_path}/script/process/reaper", :via => restart_via
  end

desc "Rolls back to the previously deployed version. The `current' symlink will \
be updated to point at the previously deployed version, and then the current \
release will be removed from the servers. You'll generally want to call \
`rollback' instead, as it performs a `restart' as well."
  task :rollback_code, :except => { :no_release => true } do
    if releases.length < 2
      abort "could not rollback the code because there is no prior release"
    else
      run "rm #{current_path}; ln -s #{previous_release} #{current_path} && rm -rf #{current_release}"
    end
  end

desc "Rolls back to a previous version and restarts. This is handy if you ever \
discover that you've deployed a lemon; `cap rollback' and you're right back \
where you were, on the previously deployed version."
  task :rollback do
    rollback_code
    restart
  end

  namespace :pending do
desc "Displays the `diff' since your last deploy. This is useful if you want \
to examine what changes are about to be deployed. Note that this might not be \
supported on all SCM's."
    task :diff, :except => { :no_release => true } do
      system(source.diff(current_revision))
    end

desc "Displays the commits since your last deploy. This is good for a summary \
of the changes that have occurred since the last deploy. Note that this might \
not be supported on all SCM's."
    task :default, :except => { :no_release => true } do
      system(source.log(current_revision))
    end
  end
end
