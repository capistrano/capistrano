module Capistrano
  module DSL

    def before(task, prerequisite, *args, &block)
      prerequisite = Rake::Task.define_task(prerequisite, *args, &block) if block_given?
      Rake::Task[task].enhance [prerequisite]
    end

    def after(task, post_task, *args, &block)
      post_task = Rake::Task.define_task(post_task, *args, &block) if block_given?
      Rake::Task[task].enhance do
        invoke(post_task)
      end
    end

    def invoke(task)
      Rake::Task[task].invoke
    end

    def t(*args)
      I18n.t(*args, scope: :capistrano)
    end

    def stages
      Dir['config/deploy/*.rb'].map { |f| File.basename(f, '.rb') }
    end

    def stage_set?
      !!fetch(:stage, false)
    end

    def configure_ssh_kit
      SSHKit.configure do |sshkit|
        sshkit.format = fetch(:format, :pretty)
        sshkit.output_verbosity = fetch(:log_level, :debug)
        sshkit.backend.configure do |backend|
          backend.pty = fetch(:pty, false)
        end
      end
    end

    def fetch(key, default=nil)
      config.fetch(key, default)
    end

    def set(key, value)
      config.set(key, value)
    end

    def role(*args)
      config.roles.values_at(*args).flatten
    end

    def all
      config.roles.values.flatten
    end

    def config
      Env.configuration
    end

    def deploy_path
      "#{fetch(:deploy_to)}/current"
    end

    def shared_path
      "#{fetch(:deploy_to)}/shared"
    end

    def deploy_user
      fetch(:user)
    end

    def error(message)
      #TODO logging
    end
  end
end
