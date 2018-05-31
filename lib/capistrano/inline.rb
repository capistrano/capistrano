# Provide a mechanism for running Capistrano within a script, with no
# dependencies on a Capfile, deploy.rb, or stage configuration files.
#
# Example:
#
# require "capistrano/inline"
#
# set :stage, "production"
# set :application, "my_app_name"
# set :repo_url, "git@github.com:username/repository.git"
#
# server "myapp.example.com", :user => "deployer", :roles => %w(app db web)
#
# invoke "production"
# invoke "deploy"
#
require "capistrano/all"

# Override DSL methods in order to disable file system searches.
module Capistrano
  module Inline
    def stages
      [fetch(:stage)]
    end

    def deploy_config_path
      nil
    end

    def stage_config_path
      nil
    end
  end
end
extend Capistrano::Inline

set :stage, "production"

require "capistrano/setup"
require "capistrano/deploy"
