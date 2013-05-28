require 'set'
module Capistrano
  class Configuration
    class Servers
      include Enumerable

      def add_host(host, properties = {})
        find_or_create_server(host).tap do |host|
          Array(properties.delete(:roles) || properties.delete("roles")).each do |role|
            host.add_role(role)
          end
          properties.each do |key, value|
            unless host.properties.respond_to?(key)
              host.properties.send(:"#{key}=", value)
            end
          end
          servers.add host
        end
      end

      def add_role(role, hosts)
        Array(hosts).each do |host|
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
