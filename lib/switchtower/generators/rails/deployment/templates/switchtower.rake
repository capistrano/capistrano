# =============================================================================
# A set of rake tasks for invoking the SwitchTower automation utility.
# =============================================================================

desc "Push the latest revision into production using the release manager"
task :deploy do
  system "script/switchtower -vvvv -r config/<%= recipe_file %> -a deploy"
end

desc "Rollback to the release before the current release in production"
task :rollback do
  system "script/switchtower -vvvv -r config/<%= recipe_file %> -a rollback"
end

desc "Enumerate all available deployment tasks"
task :show_deploy_tasks do
  system "script/switchtower -r config/<%= recipe_file %> -a show_tasks"
end

desc "Execute a specific action using the release manager"
task :remote_exec do
  unless ENV['ACTION']
    raise "Please specify an action (or comma separated list of actions) via the ACTION environment variable"
  end

  actions = ENV['ACTION'].split(",").map { |a| "-a #{a}" }.join(" ")
  system "script/switchtower -vvvv -r config/<%= recipe_file %> #{actions}"
end
