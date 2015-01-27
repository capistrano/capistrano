module Capistrano
  module DSL
    module Env

      def configure_backend
        env.configure_backend
      end

      def fetch(key, default=nil, &block)
        env.fetch(key, default, &block)
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

      def set_if_empty(key, value)
        env.set_if_empty(key, value)
      end

      def delete(key)
        env.delete(key)
      end

      def ask(key, value, options={})
        env.ask(key, value, options)
      end

      def role(name, servers, options={})
        env.role(name, servers, options)
      end

      def server(name, properties={})
        env.server(name, properties)
      end

      def roles(*names)
        env.roles_for(names.flatten)
      end

      def release_roles(*names)
        if names.last.is_a? Hash
          names.last.merge!({ :exclude => :no_release })
        else
          names << { exclude: :no_release }
        end
        roles(*names)
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
