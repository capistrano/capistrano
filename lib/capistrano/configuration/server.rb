require 'set'
module Capistrano
  class Configuration
    class Server < SSHKit::Host

      def add_roles(roles)
        Array(roles).each { |role| add_role(role) }
      end

      def add_role(role)
        roles.add role.to_sym
      end

      def has_role?(role)
        roles.include? role.to_sym
      end

      def matches?(host)
        hostname == Server.new(host).hostname
      end

      def roles
        properties.cap_roles ||= Set.new
      end

      def primary?
        self if fetch(:primary?)
      end

      def with(properties)
        properties.each { |key, value| add_property(key, value) }
        self
      end

      def fetch(key)
        properties.send(key)
      end

      def set(key, value)
        properties.send(:"#{key}=", value) unless set?(key)
      end

      def set?(key)
        properties.respond_to?(key)
      end

      private

      def add_property(key, value)
        if key.to_sym == :roles
          add_roles(value)
        else
          set(key, value)
        end
      end

    end
  end
end
