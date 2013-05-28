require 'set'
module Capistrano
  class Configuration
    class Server < SSHKit::Host

      def add_role(role)
        roles << role
      end

      def has_role?(role)
        roles.include? role
      end

      def matches?(host)
        hostname == Server.new(host).hostname
      end

      def roles
        properties.roles ||= Set.new
      end
    end
  end
end
