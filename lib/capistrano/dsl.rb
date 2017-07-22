require "capistrano/dsl/task_enhancements"
require "capistrano/dsl/paths"
require "capistrano/dsl/stages"
require "capistrano/dsl/env"
require "capistrano/configuration/filter"

module Capistrano
  module DSL
    include TaskEnhancements
    include Env
    include Paths
    include Stages

    def invoke(task_name, *args)
      task = Rake::Task[task_name]
      # NOTE: We access instance variable since the accessor was only added recently. Once Capistrano depends on rake 11+, we can revert the following line
      if task && task.instance_variable_get(:@already_invoked)
        file, line, = caller.first.split(":")
        colors = SSHKit::Color.new($stderr)
        $stderr.puts colors.colorize("Skipping task `#{task_name}'.", :yellow)
        $stderr.puts "Capistrano tasks may only be invoked once. Since task `#{task}' was previously invoked, invoke(\"#{task_name}\") at #{file}:#{line} will be skipped."
        $stderr.puts "If you really meant to run this task again, use invoke!(\"#{task_name}\")"
        $stderr.puts colors.colorize("THIS BEHAVIOR MAY CHANGE IN A FUTURE VERSION OF CAPISTRANO. Please join the conversation here if this affects you.", :red)
        $stderr.puts colors.colorize("https://github.com/capistrano/capistrano/issues/1686", :red)
      end
      task.invoke(*args)
    end

    def invoke!(task_name, *args)
      task = Rake::Task[task_name]
      task.reenable
      task.invoke(*args)
    end

    def t(key, options={})
      I18n.t(key, options.merge(scope: :capistrano))
    end

    def scm
      fetch(:scm)
    end

    def sudo(*args)
      execute :sudo, *args
    end

    def revision_log_message
      fetch(:revision_log_message,
            t(:revision_log_message,
              branch: fetch(:branch),
              user: local_user,
              sha: fetch(:current_revision),
              release: fetch(:release_timestamp)))
    end

    def rollback_log_message
      t(:rollback_log_message, user: local_user, release: fetch(:rollback_timestamp))
    end

    def local_user
      fetch(:local_user)
    end

    def lock(locked_version)
      VersionValidator.new(locked_version).verify
    end

    # rubocop:disable Security/MarshalLoad
    def on(hosts, options={}, &block)
      subset_copy = Marshal.dump(Configuration.env.filter(hosts))
      SSHKit::Coordinator.new(Marshal.load(subset_copy)).each(options, &block)
    end
    # rubocop:enable Security/MarshalLoad

    def run_locally(&block)
      SSHKit::Backend::Local.new(&block).run
    end

    # Catch common beginner mistake and give a helpful error message on stderr
    def execute(*)
      file, line, = caller.first.split(":")
      colors = SSHKit::Color.new($stderr)
      $stderr.puts colors.colorize("Warning: `execute' should be wrapped in an `on' scope in #{file}:#{line}.", :red)
      $stderr.puts
      $stderr.puts "  task :example do"
      $stderr.puts colors.colorize("    on roles(:app) do", :yellow)
      $stderr.puts "      execute 'whoami'"
      $stderr.puts colors.colorize("    end", :yellow)
      $stderr.puts "  end"
      $stderr.puts
      raise NoMethodError, "undefined method `execute' for main:Object"
    end
  end
end
extend Capistrano::DSL
