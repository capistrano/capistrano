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

      def fetch_primary(role)
        hosts = fetch([role])
        primary_host = hosts.find(&:primary) || hosts.first
        HostFilter.for([primary_host]).first
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
