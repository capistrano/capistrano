module Capistrano
  module DSL
    module Env

      def configure_backend
        env.configure_backend
      end

      def fetch(key, default=nil)
        env.fetch(key, default)
      end

      def any?(key)
        value = fetch(key)
        if value && value.respond_to?(:any?)
          value.any?
        else
          !fetch(key).nil?
        end
      end

      def set(key, value)
        env.set(key, value)
      end

      def ask(key, value)
        env.ask(key, value)
      end

      def role(name, servers, options={})
        env.role(name, servers, options)
      end

      def server(name, properties={})
        env.server(name, properties)
      end

      def roles(*names)
        env.roles_for(names)
      end

      def primary(role)
        env.primary(role)
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
