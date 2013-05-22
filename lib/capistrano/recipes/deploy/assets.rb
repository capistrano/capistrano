require 'json'

load 'deploy' unless defined?(_cset)

_cset :asset_env, "RAILS_GROUPS=assets"
_cset :assets_prefix, "assets"
_cset :shared_assets_prefix, "assets"
_cset :assets_role, [:web]
_cset :expire_assets_after, (3600 * 24 * 7)

_cset :normalize_asset_timestamps, false

before 'deploy:finalize_update',   'deploy:assets:symlink'
after  'deploy:update_code',       'deploy:assets:precompile'
before 'deploy:assets:precompile', 'deploy:assets:update_asset_mtimes'
after  'deploy:cleanup',           'deploy:assets:clean_expired'
after  'deploy:rollback:revision', 'deploy:assets:rollback'

def shared_manifest_path
  @shared_manifest_path ||= capture("ls #{shared_path.shellescape}/#{shared_assets_prefix}/manifest*").strip
end

# Parses manifest and returns array of uncompressed and compressed asset filenames with and without digests
# "Intelligently" determines format of string - supports YAML and JSON
def parse_manifest(str)
  assets_hash = str[0,1] == '{' ? JSON.parse(str)['assets'] : YAML.load(str)

  assets_hash.to_a.flatten.map {|a| [a, "#{a}.gz"] }.flatten
end

namespace :deploy do
  namespace :assets do
    desc <<-DESC
      [internal] This task will set up a symlink to the shared directory \
      for the assets directory. Assets are shared across deploys to avoid \
      mid-deploy mismatches between old application html asking for assets \
      and getting a 404 file not found error. The assets cache is shared \
      for efficiency. If you customize the assets path prefix, override the \
      :assets_prefix variable to match. If you customize shared assets path \
      prefix, override :shared_assets_prefix variable to match.
    DESC
    task :symlink, :roles => lambda { assets_role }, :except => { :no_release => true } do
      run <<-CMD.compact
        rm -rf #{latest_release}/public/#{assets_prefix} &&
        mkdir -p #{latest_release}/public &&
        mkdir -p #{shared_path}/#{shared_assets_prefix} &&
        ln -s #{shared_path}/#{shared_assets_prefix} #{latest_release}/public/#{assets_prefix}
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
    task :precompile, :roles => lambda { assets_role }, :except => { :no_release => true } do
      run <<-CMD.compact
        cd -- #{latest_release} && 
        RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} #{rake} assets:precompile
      CMD

      if capture("ls -1 #{shared_path.shellescape}/#{shared_assets_prefix}/manifest* | wc -l").to_i > 1
        raise "More than one asset manifest file was found in '#{shared_path.shellescape}/#{shared_assets_prefix}'.  If you are upgrading a Rails 3 application to Rails 4, follow these instructions: http://github.com/capistrano/capistrano/wiki/Upgrading-to-Rails-4#asset-pipeline"
      end

      # Sync manifest filenames across servers if our manifest has a random filename
      if shared_manifest_path =~ /manifest-.+\./
        run <<-CMD.compact
          [ -e #{shared_manifest_path.shellescape} ] || mv -- #{shared_path.shellescape}/#{shared_assets_prefix}/manifest* #{shared_manifest_path.shellescape}
        CMD
      end

      # Copy manifest to release root (for clean_expired task)
      run <<-CMD.compact
        cp -- #{shared_manifest_path.shellescape} #{current_release.to_s.shellescape}/assets_manifest#{File.extname(shared_manifest_path)}
      CMD
    end

    desc <<-DESC
      [internal] Updates the mtimes for assets that are required by the current release.
      This task runs before assets:precompile.
    DESC
    task :update_asset_mtimes, :roles => lambda { assets_role }, :except => { :no_release => true } do
      # Fetch assets/manifest contents.
      manifest_content = capture("[ -e #{shared_path.shellescape}/#{shared_assets_prefix}/manifest* ] && cat #{shared_path.shellescape}/#{shared_assets_prefix}/manifest* || echo").strip

      if manifest_content != ""
        current_assets = parse_manifest(manifest_content)
        logger.info "Updating mtimes for ~#{current_assets.count} assets..."
        put current_assets.map{|a| "#{shared_path}/#{shared_assets_prefix}/#{a}" }.join("\n"), "#{deploy_to}/TOUCH_ASSETS", :via => :scp
        run <<-CMD.compact
          cat #{deploy_to.shellescape}/TOUCH_ASSETS | while read asset; do
            touch -c -- "$asset";
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
    task :clean, :roles => lambda { assets_role }, :except => { :no_release => true } do
      run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:clean"
    end

    desc <<-DESC
      Clean up any assets that haven't been deployed for more than :expire_assets_after seconds.
      Default time to keep old assets is one week. Set the :expire_assets_after variable
      to change the assets expiry time. Assets will only be deleted if they are not required by
      an existing release.
    DESC
    task :clean_expired, :roles => lambda { assets_role }, :except => { :no_release => true } do
      # Fetch all assets_manifest contents.
      manifests_output = capture <<-CMD.compact
        for manifest in #{releases_path.shellescape}/*/assets_manifest.*; do
          cat -- "$manifest" 2> /dev/null && printf ':::' || true;
        done
      CMD
      manifests = manifests_output.split(':::')

      if manifests.empty?
        logger.info "No manifests in #{releases_path}/*/assets_manifest.*"
      else
        logger.info "Fetched #{manifests.count} manifests from #{releases_path}/*/assets_manifest.*"
        current_assets = Set.new
        manifests.each do |content|
          current_assets += parse_manifest(content)
        end
        current_assets += [File.basename(shared_manifest_path), "sources_manifest.yml"]

        # Write the list of required assets to server.
        logger.info "Writing required assets to #{deploy_to}/REQUIRED_ASSETS..."
        escaped_assets = current_assets.sort.join("\n").gsub("\"", "\\\"") << "\n"
        put escaped_assets, "#{deploy_to}/REQUIRED_ASSETS", :via => :scp

        # Finds all files older than X minutes, then removes them if they are not referenced
        # in REQUIRED_ASSETS.
        expire_after_mins = (expire_assets_after.to_f / 60.0).to_i
        logger.info "Removing assets that haven't been deployed for #{expire_after_mins} minutes..."
        # LC_COLLATE=C tells the `sort` and `comm` commands to sort files in byte order.
        run <<-CMD.compact
          cd -- #{deploy_to.shellescape}/ &&
          LC_COLLATE=C sort REQUIRED_ASSETS -o REQUIRED_ASSETS &&
          cd -- #{shared_path.shellescape}/#{shared_assets_prefix}/ &&
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
      to shared/assets/manifest, and finally recompiling or regenerating nondigest assets.
    DESC
    task :rollback, :roles => lambda { assets_role }, :except => { :no_release => true } do
      previous_manifest = capture("ls #{previous_release.shellescape}/assets_manifest.*").strip
      if capture("[ -e #{previous_manifest.shellescape} ] && echo true || echo false").strip != 'true'
        puts "#{previous_manifest} is missing! Cannot roll back assets. " <<
             "Please run deploy:assets:precompile to update your assets when the rollback is finished."
      else
        # If the user is rolling back a Rails 4 app to Rails 3
        if File.extname(previous_manifest) == '.yml' && File.extname(shared_manifest_path) == '.json'
          # Remove the existing JSON manifest
          run "rm -f -- #{shared_manifest_path.shellescape}"

          # Restore the manifest to the Rails 3 path
          restored_manifest_path = "#{shared_path.shellescape}/#{shared_assets_prefix}/manifest.yml"
        else
          # If the user is not rolling back from Rails 4 to 3, we just want to replace the current manifest
          restored_manifest_path = shared_manifest_path
        end

        run <<-CMD.compact
          cd -- #{previous_release.shellescape} &&
          cp -f -- #{previous_manifest.shellescape} #{restored_manifest_path.shellescape} &&
          [ -z "$(#{rake} -P | grep assets:precompile:nondigest)" ] || #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} assets:precompile:nondigest
        CMD
      end
    end
  end
end
