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
        hostname == host
      end

      def roles
        @roles ||= Set.new
      end
    end
  end
end
