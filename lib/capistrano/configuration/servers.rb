require 'set'
require_relative 'servers/role_filter'
require_relative 'servers/host_filter'
module Capistrano
  class Configuration
    class Servers
      include Enumerable

      def add_host(host, properties={})
        servers.add server(host).with(properties)
      end

      def add_role(role, hosts, options={})
        Array(hosts).each { |host| add_host(host, options.merge(roles: role)) }
      end

      def roles_for(names)
        options = extract_options(names)
        fetch_roles(names, options)
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
        servers.find { |server| server.matches? Server[host] } || Server[host]
      end

      def fetch(role)
        servers.find_all { |server| server.has_role? role}
      end

      def fetch_roles(required, options)
        filter_roles = RoleFilter.for(required, available_roles)
        HostFilter.for(select(servers_with_roles(filter_roles), options))
      end

      def servers_with_roles(roles)
        roles.flat_map { |role| fetch role }.uniq
      end

      def select(servers, options)
        servers.select { |server| server.select?(options) }
      end

      def available_roles
        servers.flat_map { |server| server.roles_array }.uniq
      end

      def servers
        @servers ||= Set.new
      end

      def extract_options(array)
        array.last.is_a?(::Hash) ? array.pop : {}
      end
    end
  end
end
