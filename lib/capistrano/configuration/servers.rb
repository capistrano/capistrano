require 'set'
require 'capistrano/configuration'
require 'capistrano/configuration/filter'

module Capistrano
  class Configuration
    class Servers
      include Enumerable

      def add_host(host, properties={})
        servers.add server(host).with(properties)
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

      def fetch_primary(role)
        hosts = roles_for([role])
        hosts.find(&:primary) || hosts.first
      end

      def each
        servers.each { |server| yield server }
      end

      private

      def server(host)
        new_host = Server[host]
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
