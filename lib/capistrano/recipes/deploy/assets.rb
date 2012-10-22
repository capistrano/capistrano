load 'deploy' unless defined?(_cset)

_cset :asset_env, "RAILS_GROUPS=assets"
_cset :assets_prefix, "assets"
_cset :assets_role, [:web]

_cset :normalize_asset_timestamps, false
_cset :precompile_only_if_changed, false

before 'deploy:finalize_update', 'deploy:assets:symlink'
after 'deploy:update_code', 'deploy:assets:precompile'

namespace :deploy do
  namespace :assets do
    desc <<-DESC
      [internal] This task will set up a symlink to the shared directory \
      for the assets directory. Assets are shared across deploys to avoid \
      mid-deploy mismatches between old application html asking for assets \
      and getting a 404 file not found error. The assets cache is shared \
      for efficiency. If you customize the assets path prefix, override the \
      :assets_prefix variable to match.
    DESC
    task :symlink, :roles => assets_role, :except => { :no_release => true } do
      run <<-CMD
        rm -rf #{latest_release}/public/#{assets_prefix} &&
        mkdir -p #{latest_release}/public &&
        mkdir -p #{shared_path}/assets &&
        ln -s #{shared_path}/assets #{latest_release}/public/#{assets_prefix}
      CMD
    end

    desc <<-DESC
      Run the asset precompilation rake task. You can specify the full path \
      to the rake executable by setting the rake variable. You can also \
      specify additional environment variables to pass to rake via the \
      asset_env variable. If you set the precompile_only_if_changed option \
      as true it will precompile assets only if there are any changes since \
      the last release. The defaults are:

        set :rake,      "rake"
        set :rails_env, "production"
        set :asset_env, "RAILS_GROUPS=assets"
        set :precompile_only_if_changed, false
    DESC
    task :precompile, :roles => assets_role, :except => { :no_release => true } do
      precompile_command = "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile"

      if precompile_only_if_changed
        if capture("cd #{latest_release} && #{source.local.log(previous_revision)} lib/assets vendor/assets/ app/assets/ config/ | wc -l").to_i
          run precompile_command
        else
          logger.info "Skipping assets precompilation because there were no asset changes"
        end
      else
        run precompile_command
      end
    end

    desc <<-DESC
      Run the asset clean rake task. Use with caution, this will delete \
      all of your compiled assets. You can specify the full path \
      to the rake executable by setting the rake variable. You can also \
      specify additional environment variables to pass to rake via the \
      asset_env variable. The defaults are:

        set :rake,      "rake"
        set :rails_env, "production"
        set :asset_env, "RAILS_GROUPS=assets"
    DESC
    task :clean, :roles => assets_role, :except => { :no_release => true } do
      run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:clean"
    end
  end
end
