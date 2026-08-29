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
        options = names.last.is_a?(Hash) ? names.pop.dup : {}
        options[:exclude] = :no_release
        names << options
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
