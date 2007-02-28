require 'thread'
require 'capistrano/ssh'
require 'capistrano/server_definition'

Thread.abort_on_exception = true

module Capistrano

  # Black magic. It uses threads and Net::SSH to set up a connection to a
  # gateway server, through which connections to other servers may be
  # tunnelled.
  #
  # It is used internally by Capistrano, but may be useful on its own, as well.
  #
  # Usage:
  #
  #   gateway = Capistrano::Gateway.new(Capistrano::ServerDefinition.new('gateway.example.com'))
  #
  #   sess1 = gateway.connect_to(Capistrano::ServerDefinition.new('hidden.example.com'))
  #   sess2 = gateway.connect_to(Capistrano::ServerDefinition.new('other.example.com'))
  class Gateway
    # An exception class for reporting Gateway-specific errors.
    class Error < Exception; end

    # The Thread instance driving the gateway connection.
    attr_reader :thread

    # The Net::SSH session representing the gateway connection.
    attr_reader :session

    MAX_PORT = 65535
    MIN_PORT = 1024

    def initialize(server, options={}) #:nodoc:
      @options = options
      @next_port = MAX_PORT
      @terminate_thread = false
      @port_guard = Mutex.new

      mutex = Mutex.new
      waiter = ConditionVariable.new

      @thread = Thread.new do
        logger.trace "starting connection to gateway `#{server.host}'" if logger
        SSH.connect(server, @options) do |@session|
          logger.trace "gateway connection established" if logger
          Thread.pass
          mutex.synchronize { waiter.signal }
          @session.loop { !@terminate_thread }
        end
      end

      mutex.synchronize do
        Thread.pass
        waiter.wait(mutex)
      end
    end

    # Shuts down all forwarded connections and terminates the gateway.
    def shutdown!
      # cancel all active forward channels
      session.forward.active_locals.each do |lport, host, port|
        session.forward.cancel_local(lport)
      end

      # terminate the gateway thread
      @terminate_thread = true

      # wait for the gateway thread to stop
      thread.join
    end

    # Connects to the given server by opening a forwarded port from the local
    # host to the server, via the gateway, and then opens and returns a new
    # Net::SSH connection via that port.
    def connect_to(server)
      connection = nil
      logger.trace "establishing connection to `#{server.host}' via gateway" if logger
      local_port = next_port

      thread = Thread.new do
        begin
          local_host = ServerDefinition.new("127.0.0.1", :user => server.user, :port => local_port)
          session.forward.local(local_port, server.host, server.port || 22)
          connection = SSH.connect(local_host, @options)
          logger.trace "connected: `#{server.host}' (via gateway)" if logger
        rescue Errno::EADDRINUSE
          local_port = next_port
          retry
        rescue Exception => e
          warn "#{e.class}: #{e.message}"
          warn e.backtrace.join("\n")
        end
      end

      thread.join
      connection or raise Error, "could not establish connection to `#{server.host}'"
    end

    private

      def logger
        @options[:logger]
      end

      def next_port
        @port_guard.synchronize do
          port = @next_port
          @next_port -= 1
          @next_port = MAX_PORT if @next_port < MIN_PORT
          port
        end
      end
  end
end
