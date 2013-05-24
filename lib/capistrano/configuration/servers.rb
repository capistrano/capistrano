require 'set'
module Capistrano
  class Configuration
    class Servers
      include Enumerable

      def add_role(role, hosts)
        hosts.each do |host|
          server = find_or_create_server(host)
          server.add_role(role)
          servers.add server
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

      def find_or_create_server(host)
        servers.find { |server| server.matches?(host) } || Server.new(host)
      end

      def fetch(name)
        servers.find_all { |server| server.has_role? name }
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
