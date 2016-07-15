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

    def invoke(task, *args)
      Rake::Task[task].invoke(*args)
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

    def on(hosts, options={}, &block)
      subset_copy = Marshal.dump(Configuration.env.filter(hosts))
      SSHKit::Coordinator.new(Marshal.load(subset_copy)).each(options, &block)
    end

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
