load 'deploy' unless defined?(_cset)

_cset :asset_env, "RAILS_GROUPS=assets"
_cset :assets_prefix, "assets"
_cset :assets_role, [:web]
_cset :expire_assets_after, (3600 * 24 * 7)

_cset :normalize_asset_timestamps, false

before 'deploy:finalize_update',   'deploy:assets:symlink'
after  'deploy:update_code',       'deploy:assets:precompile'
before 'deploy:assets:precompile', 'deploy:assets:update_asset_mtimes'
after  'deploy:cleanup',           'deploy:assets:clean_expired'
after  'deploy:rollback:revision', 'deploy:assets:rollback'

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
      run <<-CMD.compact
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
    task :precompile, :roles => assets_role, :except => { :no_release => true } do
      run <<-CMD.compact
        cd -- #{latest_release.shellescape} &&
        #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} assets:precompile &&
        cp -- #{shared_path.shellescape}/assets/manifest.yml #{current_release.shellescape}/assets_manifest.yml
      CMD
    end

    desc <<-DESC
      [internal] Updates the mtimes for assets that are required by the current release.
      This task runs before assets:precompile.
    DESC
    task :update_asset_mtimes, :roles => assets_role, :except => { :no_release => true } do
      # Fetch assets/manifest.yml contents.
      manifest_path = "#{shared_path}/assets/manifest.yml"
      manifest_yml = capture("[ -e #{manifest_path.shellescape} ] && cat #{manifest_path.shellescape} || echo").strip

      if manifest_yml != ""
        manifest = YAML.load(manifest_yml)
        current_assets = manifest.to_a.flatten.map {|a| [a, "#{a}.gz"] }.flatten
        logger.info "Updating mtimes for ~#{current_assets.count} assets..."
        put current_assets.map{|a| "#{shared_path}/assets/#{a}" }.join("\n"), "#{deploy_to}/TOUCH_ASSETS"
        run <<-CMD.compact
          cat #{deploy_to.shellescape}/TOUCH_ASSETS | while read asset; do
            touch -cm -- "$asset";
          done &&
          rm -f -- #{deploy_to.shellescape}/TOUCH_ASSETS
        CMD
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

    desc <<-DESC
      Clean up any assets that haven't been deployed for more than :expire_assets_after seconds.
      Default time to keep old assets is one week. Set the :expire_assets_after variable
      to change the assets expiry time. Assets will only be deleted if they are not required by
      an existing release.
    DESC
    task :clean_expired, :roles => assets_role, :except => { :no_release => true } do
      # Fetch all assets_manifest.yml contents.
      manifests_output = capture <<-CMD.compact
        for manifest in #{releases_path.shellescape}/*/assets_manifest.yml; do
          cat -- "$manifest" 2> /dev/null && printf ':::' || true;
        done
      CMD
      manifests = manifests_output.split(':::')

      if manifests.empty?
        logger.info "No manifests in #{releases_path}/*/assets_manifest.yml"
      else
        logger.info "Fetched #{manifests.count} manifests from #{releases_path}/*/assets_manifest.yml"
        current_assets = Set.new
        manifests.each do |yaml|
          manifest = YAML.load(yaml)
          current_assets += manifest.to_a.flatten.map {|f| [f, "#{f}.gz"] }.flatten
        end
        current_assets += %w(manifest.yml sources_manifest.yml)

        # Write the list of required assets to server.
        logger.info "Writing required assets to #{deploy_to}/REQUIRED_ASSETS..."
        escaped_assets = current_assets.sort.join("\n").gsub("\"", "\\\"") << "\n"
        put escaped_assets, "#{deploy_to}/REQUIRED_ASSETS"

        # Finds all files older than X minutes, then removes them if they are not referenced
        # in REQUIRED_ASSETS.
        expire_after_mins = (expire_assets_after.to_f / 60.0).to_i
        logger.info "Removing assets that haven't been deployed for #{expire_after_mins} minutes..."
        # LC_COLLATE=C tells the `sort` and `comm` commands to sort files in byte order.
        run <<-CMD.compact
          cd -- #{shared_path.shellescape}/assets/ &&
          for f in $(
            find * -mmin +#{expire_after_mins.to_s.shellescape} -type f | LC_COLLATE=C sort |
            LC_COLLATE=C comm -23 -- - #{deploy_to.shellescape}/REQUIRED_ASSETS
          ); do
            echo "Removing unneeded asset: $f";
            rm -f -- "$f";
          done;
          rm -f -- #{deploy_to.shellescape}/REQUIRED_ASSETS
        CMD
      end
    end

    desc <<-DESC
      Rolls back assets to the previous release by symlinking the release's manifest
      to shared/assets/manifest.yml, and finally recompiling or regenerating nondigest assets.
    DESC
    task :rollback, :roles => assets_role, :except => { :no_release => true } do
      previous_manifest = "#{previous_release}/assets_manifest.yml"
      if capture("[ -e #{previous_manifest.shellescape} ] && echo true || echo false").strip != 'true'
        puts "#{previous_manifest} is missing! Cannot roll back assets. " <<
             "Please run deploy:assets:precompile to update your assets when the rollback is finished."
        return false
      else
        run <<-CMD.compact
          cd -- #{previous_release.shellescape} &&
          cp -f -- #{previous_manifest.shellescape} #{shared_path.shellescape}/assets/manifest.yml &&
          #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} assets:precompile:nondigest
        CMD
      end
    end
  end
end
