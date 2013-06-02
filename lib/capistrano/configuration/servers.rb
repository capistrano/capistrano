require 'set'
module Capistrano
  class Configuration
    class Servers
      include Enumerable

      def add_host(host, properties={})
        servers.add server(host).with(properties)
      end

      def add_role(role, hosts)
        Array(hosts).each { |host| add_host(host, roles: role) }
      end

      def roles_for(names)
        options = extract_options(names)
        fetch_roles(names, options)
      end

      def fetch_primary(role)
        hosts = fetch(role)
        hosts.find(&:primary?) || hosts.first
      end

      def each
        servers.each { |server| yield server }
      end

      private

      def server(host)
        if host.is_a? Server
          host
        else
          servers.find { |server| server.matches?(host) } || Server.new(host)
        end
      end

      def fetch(role)
        servers.find_all { |server| server.has_role? role}
      end

      def fetch_roles(names, options)
        if Array(names).map(&:to_sym).include?(:all)
          filter(servers, options)
        else
          role_servers = Array(names).flat_map { |name| fetch name }.uniq
          filter(role_servers, options)
        end
      end

      def filter(servers, options)
        Filter.new(servers, options).filtered_servers
      end

      def servers
        @servers ||= Set.new
      end

      def extract_options(array)
        array.last.is_a?(::Hash) ? array.pop : {}
      end

      class Filter
        def initialize(servers, options)
          @servers, @options = servers, options
        end

        def filtered_servers
          if servers_with_filter.any?
            servers_with_filter
          else
            fail I18n.t(:filter_removes_all_servers)
          end
        end

        private
        attr_reader :options, :servers

        def servers_with_filter
          @servers_with_filter ||= servers.select(&filter)
        end

        def filter_option
          options[:filter] || options[:select] || all
        end

        def filter
          if filter_option.respond_to?(:call)
            filter_option
          else
            lambda { |server| server.fetch(filter_option) }
          end
        end

        def all
          lambda { |server| :all }
        end

      end
    end
  end
end
