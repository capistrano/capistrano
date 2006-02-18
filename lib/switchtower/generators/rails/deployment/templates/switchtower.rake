# =============================================================================
# A set of rake tasks for invoking the SwitchTower automation utility.
# =============================================================================

# Invoke the given actions via SwitchTower
def switchtower_invoke(*actions)
  begin
    require 'rubygems'
  rescue LoadError
    # no rubygems to load, so we fail silently
  end

  options = actions.last.is_a?(Hash) ? actions.pop : {}

  args = %w[-r config/deploy]
  verbose = options[:verbose] || "-vvvvv"
  args << verbose

  args = %w[-vvvvv -r config/<%= recipe_file %>]
  args.concat(actions.map { |act| ["-a", act.to_s] }.flatten)
  SwitchTower::CLI.new(args).execute!
end

desc "Push the latest revision into production"
task :deploy do
  switchtower_invoke :deploy
end

desc "Rollback to the release before the current release in production"
task :rollback do
  switchtower_invoke :rollback
end

desc "Describe the differences between HEAD and the last production release"
task :diff_from_last_deploy do
  switchtower_invoke :diff_from_last_deploy
end

desc "Enumerate all available deployment tasks"
task :show_deploy_tasks do
  switchtower_invoke :show_tasks, :verbose => ""
end

desc "Execute a specific action using switchtower"
task :remote_exec do
  unless ENV['ACTION']
    raise "Please specify an action (or comma separated list of actions) via the ACTION environment variable"
  end

  actions = ENV['ACTION'].split(",")
  switchtower_invoke(*actions)
end
