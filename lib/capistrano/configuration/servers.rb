require 'set'
module Capistrano
  class Configuration
    class Servers
      include Enumerable

      def add_host(host, properties={})
        servers.add server(host).with(properties)
      end

      def add_role(role, hosts)
        Array(hosts).each { |host| add_host(host, role: role) }
      end

      def fetch_roles(names)
        roles_for(names)
      end

      def fetch_primary(role)
        hosts = fetch(role)
        hosts.find(&:primary) || hosts.first
      end

      def each
        servers.each { |server| yield server }
      end

      private

      def server(host)
        servers.find { |server| server.matches?(host) } || Server.new(host)
      end

      def fetch(role)
        servers.find_all { |server| server.has_role? role}
      end

      def roles_for(names)
        if Array(names).map(&:to_sym).include?(:all)
          servers
        else
          Array(names).flat_map { |name| fetch name }.uniq
        end
      end

      def servers
        @servers ||= Set.new
      end
    end
  end
end
