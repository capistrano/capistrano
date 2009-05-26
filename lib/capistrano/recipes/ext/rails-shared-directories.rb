_cset :shared_children,   %w(system log pids)

after 'deploy:finalize_update' do
  # mkdir -p is making sure that the directories are there for some SCM's that don't
  # save empty folders
  run <<-CMD
    rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
    mkdir -p #{latest_release}/public &&
    mkdir -p #{latest_release}/tmp &&
    ln -s #{shared_path}/log #{latest_release}/log &&
    ln -s #{shared_path}/system #{latest_release}/public/system &&
    ln -s #{shared_path}/pids #{latest_release}/tmp/pids
  CMD

  if fetch(:normalize_asset_timestamps, true)
    stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
    asset_paths = %w(images stylesheets javascripts).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
    run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
  end
  
end