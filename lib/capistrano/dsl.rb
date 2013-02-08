module Capistrano
  module DSL

    def t(key)
      I18n.t(key, scope: :capistrano)
    end

    def stages
      Dir["config/deploy/*.rb"].map { |f| File.basename(f, ".rb") }
    end

    def stage_set?
      !!env.stage
    end

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

    def configure_ssh_kit
      SSHKit.configure do |sshkit|
        sshkit.format = env.format
      end
    end

    def invoke(task)
      Rake::Task[task].invoke
    end

    def fetch(key)
      env.fetch(key)
    end

    def set(key, value)
      env.set(key, value)
    end

    def role(name)
      roles[name]
    end

    def all_roles
      roles.values.flatten
    end

    def configuration
      Env.configuration
    end

    def env
      configuration
    end

    def roles
      env.roles
    end
  end
end
