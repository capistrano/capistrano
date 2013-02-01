module Capistrano
  module DSL

    def invoke(task)
      ::Rake::Task["deploy:#{task}"].invoke
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
