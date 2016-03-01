require "set"
require "capistrano/configuration"
require "capistrano/configuration/filter"

module Capistrano
  class Configuration
    class Servers
      include Enumerable

      def add_host(host, properties={})
        new_host = Server[host]
        if (server = servers.find { |s| s.matches? new_host })
          server.user = new_host.user if new_host.user
          server.with(properties)
        else
          servers << new_host.with(properties)
        end
      end

      def add_role(role, hosts, options={})
        options_deepcopy = Marshal.dump(options.merge(roles: role))
        Array(hosts).each { |host| add_host(host, Marshal.load(options_deepcopy)) }
      end

      def roles_for(names)
        options = extract_options(names)
        s = Filter.new(:role, names).filter(servers)
        s.select { |server| server.select?(options) }
      end

      def role_properties_for(rolenames)
        roles = rolenames.to_set
        rps = Set.new unless block_given?
        roles_for(rolenames).each do |host|
          host.roles.intersection(roles).each do |role|
            [host.properties.fetch(role)].flatten(1).each do |props|
              if block_given?
                yield host, role, props
              else
                rps << (props || {}).merge(role: role, hostname: host.hostname)
              end
            end
          end
        end
        block_given? ? nil : rps
      end

      def fetch_primary(role)
        hosts = roles_for([role])
        hosts.find(&:primary) || hosts.first
      end

      def each
        servers.each { |server| yield server }
      end

      private

      def servers
        @servers ||= []
      end

      def extract_options(array)
        array.last.is_a?(::Hash) ? array.pop : {}
      end
    end
  end
end
