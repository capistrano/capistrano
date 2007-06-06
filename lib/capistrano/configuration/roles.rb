require 'capistrano/server_definition'

module Capistrano
  class Configuration
    module Roles
      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_roles, :initialize
        base.send :alias_method, :initialize, :initialize_with_roles
      end

      # The hash of roles defined for this configuration. Each entry in the
      # hash points to an array of server definitions that belong in that
      # role.
      attr_reader :roles

      def initialize_with_roles(*args) #:nodoc:
        initialize_without_roles(*args)
        @roles = Hash.new { |h,k| h[k] = [] }
      end

      # Define a new role and its associated servers. You must specify at least
      # one host for each role. Also, you can specify additional information
      # (in the form of a Hash) which can be used to more uniquely specify the
      # subset of servers specified by this specific role definition.
      #
      # Usage:
      #
      #   role :db,  "db1.example.com", "db2.example.com"
      #   role :db,  "master.example.com", :primary => true
      #   role :app, "app1.example.com", "app2.example.com"
      #
      # You can also encode the username and port number for each host in the
      # server string, if needed:
      #
      #   role :web,  "www@web1.example.com"
      #   role :file, "files.example.com:4144"
      #   role :db,   "admin@db3.example.com:1234"
      #
      # Lastly, username and port number may be passed as options, if that is
      # preferred; note that the options apply to all servers defined in
      # that call to "role":
      #
      #   role :web, "web2", "web3", :user => "www", :port => 2345
      def role(which, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        which = which.to_sym
        args.each { |host| roles[which] << ServerDefinition.new(host, options) }
      end
    end
  end
end
