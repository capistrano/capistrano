require 'set'
require 'capistrano/configuration'
require 'capistrano/configuration/filter'

module Capistrano
  class Configuration
    class Servers
      include Enumerable

      def add_host(host, properties={})
        servers.add server(host, properties).with(properties)
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
                rps << (props || {}).merge( role: role, hostname: host.hostname )
              end
            end
          end
        end
        block_given? ? nil: rps
      end

      def fetch_primary(role)
        hosts = roles_for([role])
        hosts.find(&:primary) || hosts.first
      end

      def each
        servers.each { |server| yield server }
      end

      private

      def server(host, properties)
        new_host = Server[host]
        new_host.with({user: properties[:user]}) unless properties[:user].nil?
        new_host.with({port: properties[:port]}) unless properties[:port].nil?
        servers.find { |server| server.matches? new_host } || new_host
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
