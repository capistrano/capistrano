require "forwardable"

module Capistrano
  module DSL
    module Env
      extend Forwardable
      def_delegators :env,
                     :configure_backend, :fetch, :set, :set_if_empty, :delete,
                     :ask, :role, :server, :primary, :validate, :append,
                     :remove, :dry_run?, :install_plugin, :any?, :is_question?,
                     :configure_scm, :scm_plugin_installed?

      def roles(*names)
        env.roles_for(names.flatten)
      end

      def role_properties(*names, &block)
        env.role_properties_for(names, &block)
      end

      def release_roles(*names)
        if names.last.is_a? Hash
          names.last[:exclude] = :no_release
        else
          names << { exclude: :no_release }
        end
        roles(*names)
      end

      def env
        Configuration.env
      end

      def release_timestamp
        env.timestamp.strftime("%Y%m%d%H%M%S")
      end

      def asset_timestamp
        env.timestamp.strftime("%Y%m%d%H%M.%S")
      end
    end
  end
end
