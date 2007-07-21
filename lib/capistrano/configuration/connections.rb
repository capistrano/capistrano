require 'capistrano/gateway'
require 'capistrano/ssh'

module Capistrano
  class Configuration
    module Connections
      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_connections, :initialize
        base.send :alias_method, :initialize, :initialize_with_connections
      end

      # An adaptor for making the SSH interface look and act like that of the
      # Gateway class.
      class DefaultConnectionFactory #:nodoc:
        def initialize(options)
          @options = options
        end

        def connect_to(server)
          SSH.connect(server, @options)
        end
      end

      # A hash of the SSH sessions that are currently open and available.
      # Because sessions are constructed lazily, this will only contain
      # connections to those servers that have been the targets of one or more
      # executed tasks.
      attr_reader :sessions

      def initialize_with_connections(*args) #:nodoc:
        initialize_without_connections(*args)
        @sessions = {}
        @failed_sessions = []
      end

      # Indicate that the given server could not be connected to.
      def failed!(server)
        @failed_sessions << server
      end

      # Query whether previous connection attempts to the given server have
      # failed.
      def has_failed?(server)
        @failed_sessions.include?(server)
      end

      # Used to force connections to be made to the current task's servers.
      # Connections are normally made lazily in Capistrano--you can use this
      # to force them open before performing some operation that might be
      # time-sensitive.
      def connect!(options={})
        execute_on_servers(options) { }
      end

      # Returns the object responsible for establishing new SSH connections.
      # The factory will respond to #connect_to, which can be used to
      # establish connections to servers defined via ServerDefinition objects.
      def connection_factory
        @connection_factory ||= begin
          if exists?(:gateway)
            logger.debug "establishing connection to gateway `#{fetch(:gateway)}'"
            Gateway.new(ServerDefinition.new(fetch(:gateway)), self)
          else
            DefaultConnectionFactory.new(self)
          end
        end
      end

      # Ensures that there are active sessions for each server in the list.
      def establish_connections_to(servers)
        failed_servers = []

        # This attemps to work around the problem where SFTP uploads hang
        # for some people. A bit of investigating seemed to reveal that the
        # hang only occurred when the SSH connections were established async,
        # so this setting allows people to at least work around the problem.
        if fetch(:synchronous_connect, false)
          logger.trace "synchronous_connect: true"
          Array(servers).each { |server| safely_establish_connection_to(server, failed_servers) }
        else
          # force the connection factory to be instantiated synchronously,
          # otherwise we wind up with multiple gateway instances, because
          # each connection is done in parallel.
          connection_factory

          threads = Array(servers).map { |server| establish_connection_to(server, failed_servers) }
          threads.each { |t| t.join }
        end

        if failed_servers.any?
          errors = failed_servers.map { |h| "#{h[:server]} (#{h[:error].class}: #{h[:error].message})" }
          error = ConnectionError.new("connection failed for: #{errors.join(', ')}")
          error.hosts = failed_servers.map { |h| h[:server] }
          raise error
        end
      end

      # Determines the set of servers within the current task's scope and
      # establishes connections to them, and then yields that list of
      # servers.
      def execute_on_servers(options={})
        raise ArgumentError, "expected a block" unless block_given?

        if task = current_task
          servers = find_servers_for_task(task, options)

          if servers.empty?
            raise Capistrano::NoMatchingServersError, "`#{task.fully_qualified_name}' is only run for servers matching #{task.options.inspect}, but no servers matched"
          end

          if task.continue_on_error?
            servers.delete_if { |s| has_failed?(s) }
            return if servers.empty?
          end
        else
          servers = find_servers(options)
          raise Capistrano::NoMatchingServersError, "no servers found to match #{options.inspect}" if servers.empty?
        end

        servers = [servers.first] if options[:once]
        logger.trace "servers: #{servers.map { |s| s.host }.inspect}"

        # establish connections to those servers, as necessary
        begin
          establish_connections_to(servers)
        rescue ConnectionError => error
          raise error unless task && task.continue_on_error?
          error.hosts.each do |h|
            servers.delete(h)
            failed!(h)
          end
        end

        begin
          yield servers
        rescue RemoteError => error
          raise error unless task && task.continue_on_error?
          error.hosts.each { |h| failed!(h) }
        end
      end

      private

        # We establish the connection by creating a thread in a new method--this
        # prevents problems with the thread's scope seeing the wrong 'server'
        # variable if the thread just happens to take too long to start up.
        def establish_connection_to(server, failures=nil)
          Thread.new { safely_establish_connection_to(server, failures) }
        end

        def safely_establish_connection_to(server, failures=nil)
          sessions[server] ||= connection_factory.connect_to(server)
        rescue Exception => err
          raise unless failures
          failures << { :server => server, :error => err }
        end
    end
  end
end
