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
      env.configure_backend
    end

    def fetch(key, default=nil)
      env.fetch(key, default)
    end

    def set(key, value)
      env.set(key, value)
    end

    def role(name, servers)
      env.role(name, servers)
    end

    def roles(*names)
      env.roles_for(names)
    end

    def all
      env.all_roles
    end

    def env
      Configuration.env
    end

    def deploy_path
      "#{fetch(:deploy_to)}"
    end

    def current_path
      "#{deploy_path}/current"
    end

    def releases_path
      "#{deploy_path}/releases"
    end

    def release_path
      "#{releases_path}/#{timestamp}"
    end

    def release_timestamp
      env.timestamp.strftime("%Y%m%d%H%M%S")
    end

    def asset_timestamp
      env.timestamp.strftime("%Y%m%d%H%M.%S")
    end

    def repo_path
      "#{deploy_path}/repo"
    end

    def shared_path
      "#{deploy_path}/shared"
    end

    def revision_log
      "#{deploy_path}/revisions.log"
    end

    def deploy_user
      fetch(:user)
    end

    def info(message)
      puts message
    end

    def error(message)
      puts message
    end
  end
end
