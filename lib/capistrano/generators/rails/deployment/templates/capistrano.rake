# =============================================================================
# A set of rake tasks for invoking the Capistrano automation utility.
# =============================================================================

# Invoke the given actions via Capistrano
def cap(*parameters)
  begin
    require 'rubygems'
  rescue LoadError
    # no rubygems to load, so we fail silently
  end

  require 'capistrano/cli'

  STDERR.puts "Capistrano/Rake integration is deprecated."
  STDERR.puts "Please invoke the 'cap' command directly: `cap #{parameters.join(" ")}'"

  Capistrano::CLI.new(parameters.map { |param| param.to_s }).execute!
end

namespace :remote do
<%- config = Capistrano::Configuration.new
    config.load "standard"
    options = { :show_tasks => ", '-q'" }
    config.actor.each_task do |info| -%>
<%- unless info[:desc].empty? -%>
  desc "<%= info[:desc].scan(/.*?(?:\. |$)/).first.strip.gsub(/"/, "\\\"") %>"
<%- end -%>
  task(<%= info[:task].inspect %>) { cap <%= info[:task].inspect %><%= options[info[:task]] %> }

<%- end -%>
  desc "Execute a specific action using capistrano"
  task :exec do
    unless ENV['ACTION']
      raise "Please specify an action (or comma separated list of actions) via the ACTION environment variable"
    end

    actions = ENV['ACTION'].split(",")
    actions.concat(ENV['PARAMS'].split(" ")) if ENV['PARAMS']

    cap(*actions)
  end
end

desc "Push the latest revision into production (delegates to remote:deploy)"
task :deploy => "remote:deploy"

desc "Rollback to the release before the current release in production (delegates to remote:rollback)"
task :rollback => "remote:rollback"
