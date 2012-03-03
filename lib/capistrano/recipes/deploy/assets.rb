load 'deploy' unless defined?(_cset)

_cset :asset_env, "RAILS_GROUPS=assets"
_cset :assets_prefix, "assets"

_cset :normalize_asset_timestamps, false

before 'deploy:finalize_update', 'deploy:assets:symlink'
after 'deploy:update_code', 'deploy:assets:precompile'

namespace :deploy do
  namespace :assets do
    desc <<-DESC
      [internal] This task will set up a symlink to the shared directory \
      for the assets directory. Assets are shared across deploys to avoid \
      mid-deploy mismatches between old application html asking for assets \
      and getting a 404 file not found error. The assets cache is shared \
      for efficiency. If you cutomize the assets path prefix, override the \
      :assets_prefix variable to match.
    DESC
    task :symlink, :roles => :web, :except => { :no_release => true } do
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
      asset_env variable. The defaults are:

        set :rake,      "rake"
        set :rails_env, "production"
        set :asset_env, "RAILS_GROUPS=assets"
    DESC
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      begin
        run unindent(<<-CMD)
          cd #{latest_release};
          COUNT=`#{source.local.log(from)} -- app/assets/ lib/assets/
            vendor/assets/ | wc -l`;
          if [ #{ENV['FORCE'] ? 1 : '$COUNT'} -gt 0 ]; then
            #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile;
          else
            echo Skipping asset pre-compilation because there were no
              asset changes;
          fi
        CMD
      rescue Capistrano::CommandError => e
        # occurs when assets:precompile task is missing (prior to Rails 3.1)
        puts "Skipping task 'assets:precompile' (#{e.class}: #{e.message})"
      end # rescue
    end # task :precompile

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
    task :clean, :roles => :web, :except => { :no_release => true } do
      run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:clean"
    end
  end
end
