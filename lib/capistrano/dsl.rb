module Capistrano
  module DSL

    def t(key)
      I18n.t(key, scope: :capistrano)
    end

    def stage_set?
      !!Capistrano::Env.configuration.stage
    end

    def before(task, prerequisite, *args, &block)
      rerequisite = Rake::Task.define_task(prerequisite, *args, &block) if block_given?
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

    def fetch(key)
      configuration.fetch(key)
    end

    def set(key, value)
      configuration.set(key, value)
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

    # I prefer env.my_var
    # over fetch(:my_var)
    def env
      configuration
    end

    def roles
      Env.configuration.roles
    end
  end
end
