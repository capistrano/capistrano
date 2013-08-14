module Capistrano
  class Configuration
    module Servers
      # Identifies all servers that the given task should be executed on.
      # The options hash accepts the same arguments as #find_servers, and any
      # preexisting options there will take precedence over the options in
      # the task.
      def find_servers_for_task(task, options={})
        find_servers(task.options.merge(options))
      end

      # Attempts to find all defined servers that match the given criteria.
      # The options hash may include a :hosts option (which should specify
      # an array of host names or ServerDefinition instances), a :roles
      # option (specifying an array of roles), an :only option (specifying
      # a hash of key/value pairs that any matching server must match),
      # an :except option (like :only, but the inverse), and a
      # :skip_hostfilter option to ignore the HOSTFILTER environment variable
      # described below.
      #
      # Additionally, if the HOSTS environment variable is set, it will take
      # precedence over any other options. Similarly, the ROLES environment
      # variable will take precedence over other options. If both HOSTS and
      # ROLES are given, HOSTS wins.
      #
      # Yet additionally, if the HOSTFILTER environment variable is set, it
      # will limit the result to hosts found in that (comma-separated) list.
      #
      # If the HOSTROLEFILTER environment variable is set, it will limit the
      # result to hosts found in that (comma-separated) list of roles
      #
      # Usage:
      #
      #   # return all known servers
      #   servers = find_servers
      #
      #   # find all servers in the app role that are not exempted from
      #   # deployment
      #   servers = find_servers :roles => :app,
      #                :except => { :no_release => true }
      #
      #   # returns the given hosts, translated to ServerDefinition objects
      #   servers = find_servers :hosts => "jamis@example.host.com"
      def find_servers(options={})
        return [] if options.key?(:hosts) && (options[:hosts].nil? || [] == options[:hosts])
        return [] if options.key?(:roles) && (options[:roles].nil? || [] == options[:roles])

        hosts  = server_list_from(ENV['HOSTS'] || options[:hosts])

        if hosts.any?
          if options[:skip_hostfilter]
            hosts.uniq
          else
            filter_server_list(hosts.uniq)
          end
        else
          roles = role_list_from(ENV['ROLES'] || options[:roles] || self.roles.keys)
          roles = roles & Array(options[:roles]) if preserve_roles && !options[:roles].nil?

          only   = options[:only] || {}
          except = options[:except] || {}

          # If we don't have a def for a role it means its bogus, skip it so higher level can handle
          servers = roles.inject([]) { |list, role| list.concat(self.roles[role] || []) }
          servers = servers.select { |server| only.all? { |key,value| server.options[key] == value } }
          servers = servers.reject { |server| except.any? { |key,value| server.options[key] == value } }

          if options[:skip_hostfilter]
            servers.uniq
          else
            filter_server_list(servers.uniq)
          end
        end
      end

    protected

      def filter_server_list(servers)
        return servers unless ENV['HOSTFILTER'] or ENV['HOSTROLEFILTER']
        if ENV['HOSTFILTER']
          filters = ENV['HOSTFILTER'].split(/,/)
          servers.select { |server| filters.include?(server.host) }
        elsif ENV['HOSTROLEFILTER']
          filters = ENV['HOSTROLEFILTER'].split(/,/).map do |role|
            local_roles = roles[role.to_sym]
            if local_roles.is_a? Array
              roles[role.to_sym]
            else
              roles[role.to_sym].servers
            end
          end.flatten
          servers.select { |server| filters.include?(server) }
        end
      end

      def server_list_from(hosts)
        hosts = hosts.split(/,/) if String === hosts
        hosts = build_list(hosts)
        hosts.map { |s| String === s ? ServerDefinition.new(s.strip) : s }
      end

      def role_list_from(roles)
        roles = roles.split(/,/) if String === roles
        roles = build_list(roles)
        roles.map do |role|
          role = String === role ? role.strip.to_sym : role
          role
        end
      end

      def build_list(list)
        Array(list).map { |item| item.respond_to?(:call) ? item.call : item }.flatten
      end
    end
  end
end
