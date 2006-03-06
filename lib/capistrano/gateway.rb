require 'thread'
require 'capistrano/ssh'

Thread.abort_on_exception = true

module Capistrano

  # Black magic. It uses threads and Net::SSH to set up a connection to a
  # gateway server, through which connections to other servers may be
  # tunnelled.
  #
  # It is used internally by Actor, but may be useful on its own, as well.
  #
  # Usage:
  #
  #   config = Capistrano::Configuration.new
  #   gateway = Capistrano::Gateway.new('gateway.example.com', config)
  #
  #   sess1 = gateway.connect_to('hidden.example.com')
  #   sess2 = gateway.connect_to('other.example.com')
  class Gateway
    # The thread inside which the gateway connection itself is running.
    attr_reader :thread

    # The Net::SSH session representing the gateway connection.
    attr_reader :session

    MAX_PORT = 65535
    MIN_PORT = 1024

    def initialize(server, config) #:nodoc:
      @config = config
      @pending_forward_requests = {}
      @mutex = Mutex.new
      @next_port = MAX_PORT
      @terminate_thread = false

      waiter = ConditionVariable.new

      @thread = Thread.new do
        @config.logger.trace "starting connection to gateway #{server}"
        SSH.connect(server, @config) do |@session|
          @config.logger.trace "gateway connection established"
          @mutex.synchronize { waiter.signal }
          connection = @session.registry[:connection][:driver]
          loop do
            break if @terminate_thread
            sleep 0.1 unless connection.reader_ready?
            connection.process true
            Thread.new { process_next_pending_connection_request }
          end
        end
      end

      @mutex.synchronize { waiter.wait(@mutex) }
    end

    # Shuts down all forwarded connections and terminates the gateway.
    def shutdown!
      # cancel all active forward channels
      @session.forward.active_locals.each do |lport, host, port|
        @session.forward.cancel_local(lport)
      end

      # terminate the gateway thread
      @terminate_thread = true

      # wait for the gateway thread to stop
      @thread.join
    end

    # Connects to the given server by opening a forwarded port from the local
    # host to the server, via the gateway, and then opens and returns a new
    # Net::SSH connection via that port.
    def connect_to(server)
      @mutex.synchronize do
        @pending_forward_requests[server] = ConditionVariable.new
        @pending_forward_requests[server].wait(@mutex)
        @pending_forward_requests.delete(server)
      end
    end

    private

      def next_port
        port = @next_port
        @next_port -= 1
        @next_port = MAX_PORT if @next_port < MIN_PORT
        port
      end

      def process_next_pending_connection_request
        @mutex.synchronize do
          key = @pending_forward_requests.keys.detect { |k| ConditionVariable === @pending_forward_requests[k] } or return
          var = @pending_forward_requests[key]

          @config.logger.trace "establishing connection to #{key} via gateway"

          port = next_port

          begin
            @session.forward.local(port, key, 22)
            @pending_forward_requests[key] = SSH.connect('127.0.0.1', @config,
              port)
            @config.logger.trace "connection to #{key} via gateway established"
          rescue Errno::EADDRINUSE
            port = next_port
            retry
          rescue Object
            @pending_forward_requests[key] = nil
            raise
          ensure
            var.signal
          end
        end
      end
  end
end
