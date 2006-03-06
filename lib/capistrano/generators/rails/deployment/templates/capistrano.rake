# =============================================================================
# A set of rake tasks for invoking the Capistrano automation utility.
# =============================================================================

# Invoke the given actions via Capistrano
def capistrano_invoke(*actions)
  begin
    require 'rubygems'
  rescue LoadError
    # no rubygems to load, so we fail silently
  end

  require 'capistrano/cli'

  options = actions.last.is_a?(Hash) ? actions.pop : {}

  args = %w[-r config/deploy]
  verbose = options[:verbose] || "-vvv"
  args << verbose

  args.concat(actions.map { |act| ["-a", act.to_s] }.flatten)
  Capistrano::CLI.new(args).execute!
end

namespace :remote do
<%- config = Capistrano::Configuration.new
    config.load "standard"
    options = { :show_tasks => ", :verbose => ''" }
    config.actor.each_task do |info| -%>
<%- unless info[:desc].empty? -%>
  desc "<%= info[:desc].scan(/.*?(?:\. |$)/).first.strip.gsub(/"/, "\\\"") %>"
<%- end -%>
  task(<%= info[:task].inspect %>) { capistrano_invoke <%= info[:task].inspect %><%= options[info[:task]] %> }

<%- end -%>
  desc "Execute a specific action using capistrano"
  task :exec do
    unless ENV['ACTION']
      raise "Please specify an action (or comma separated list of actions) via the ACTION environment variable"
    end

    actions = ENV['ACTION'].split(",")
    capistrano_invoke(*actions)
  end
end

desc "Push the latest revision into production (delegates to remote:deploy)"
task :deploy => "remote:deploy"

desc "Rollback to the release before the current release in production (delegates to remote:rollback)"
task :rollback => "remote:rollback"
