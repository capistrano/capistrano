require 'set'
module Capistrano
  class Configuration
    class Server < SSHKit::Host

      def add_roles(roles)
        Array(roles).each { |role| add_role(role) }
      end

      def add_role(role)
        roles << role.to_sym
      end

      def has_role?(role)
        roles.include? role.to_sym
      end

      def matches?(host)
        hostname == Server.new(host).hostname
      end

      def roles
        properties.roles ||= Set.new
      end

      def primary
        self if properties.primary
      end

      def with(properties)
        properties.each { |property, value| add_property(property, value) }
        self
      end

      private

      def add_property(property, value)
        if property.to_sym == :role
          add_roles(value)
        else
          properties.send(:"#{property}=", value) unless properties.respond_to?(property)
        end
      end

    end
  end
end
