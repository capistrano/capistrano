require 'capistrano/dsl/task_enhancements'
require 'capistrano/dsl/paths'
require 'capistrano/dsl/logger'
require 'capistrano/dsl/stages'
require 'capistrano/dsl/env'

module Capistrano
  module DSL
    include TaskEnhancements
    include Env
    include Paths
    include Logger
    include Stages

    def invoke(task)
      Rake::Task[task].invoke
    end

    def t(*args)
      I18n.t(*args, scope: :capistrano)
    end

    def deploy_user
      fetch(:deploy_user)
    end

    def scm
      fetch(:scm)
    end

    def maintenance_page
      fetch(:maintenance_page, 'public/system/maintenance.html')
    end

    def revision_log_message
      %{Branch #{fetch(:branch)} deployed as release #{release_timestamp} by #{`whoami`}}
    end
  end
end
