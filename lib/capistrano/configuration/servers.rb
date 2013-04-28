require 'set'
module Capistrano
  class Configuration
    class Servers
      include Enumerable

      def add_role(role, hosts)
        hosts.each do |host|
          server = server_from_host(host)
          server.roles << role
          servers << server
        end
      end

      def fetch_roles(names)
        roles_for(names)
      end

      def fetch_primary(role)
        fetch(role).first
      end

      def each
        servers.each { |server| yield server }
      end

      private

      def server_from_host(host)
        servers.find { |server| server.hostname == host } || Server.new(host)
      end

      def fetch(name)
        servers.find_all { |server| server.roles.include? name }
      end

      def roles_for(names)
        if names.include?(:all)
          servers
        else
          names.flat_map { |name| fetch name }.uniq
        end
      end

      def servers
        @servers ||= Set.new
      end
    end
  end
end
