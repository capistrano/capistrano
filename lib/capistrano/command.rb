module Capistrano

  # This class encapsulates a single command to be executed on a set of remote
  # machines, in parallel.
  class Command
    class Error < RuntimeError; end

    attr_reader :command, :sessions, :options

    def initialize(command, sessions, options={}, &block) #:nodoc:
      @command = extract_environment(options) + command.strip.gsub(/\r?\n/, "\\\n")
      @sessions = sessions
      @options = options
      @callback = block
      @channels = open_channels
    end

    def logger #:nodoc:
      options[:logger]
    end

    # Processes the command in parallel on all specified hosts. If the command
    # fails (non-zero return code) on any of the hosts, this will raise a
    # RuntimeError.
    def process!
      since = Time.now
      loop do
        active = 0
        @channels.each do |ch|
          next if ch[:closed]
          active += 1
          ch.connection.process(true)
        end

        break if active == 0
        if Time.now - since >= 1
          since = Time.now
          @channels.each { |ch| ch.connection.ping! }
        end
        sleep 0.01 # a brief respite, to keep the CPU from going crazy
      end

      logger.trace "command finished" if logger

      if failed = @channels.detect { |ch| ch[:status] != 0 }
        raise Error, "command #{command.inspect} failed on #{failed[:host]}"
      end

      self
    end

    # Force the command to stop processing, by closing all open channels
    # associated with this command.
    def stop!
      @channels.each do |ch|
        ch.close unless ch[:closed]
      end
    end

    private

      def open_channels
        sessions.map do |session|
          session.open_channel do |channel|
            channel[:host] = session.host
            channel[:options] = options
            channel.request_pty :want_reply => true

            channel.on_success do |ch|
              logger.trace "executing command", ch[:host] if logger
              ch.exec command
              ch.send_data options[:data] if options[:data]
            end

            channel.on_failure do |ch|
              # just log it, don't actually raise an exception, since the
              # process method will see that the status is not zero and will
              # raise an exception then.
              logger.important "could not open channel", ch[:host] if logger
              ch.close
            end

            channel.on_data do |ch, data|
              @callback[ch, :out, data] if @callback
            end

            channel.on_extended_data do |ch, type, data|
              @callback[ch, :err, data] if @callback
            end

            channel.on_request do |ch, request, reply, data|
              ch[:status] = data.read_long if request == "exit-status"
            end

            channel.on_close do |ch|
              ch[:closed] = true
            end
          end
        end
      end

      # prepare a space-separated sequence of variables assignments
      # intended to be prepended to a command, so the shell sets
      # the environment before running the command.
      # i.e.: options[:env] = {'PATH' => '/opt/ruby/bin:$PATH',
      #                        'TEST' => '( "quoted" )'}
      # extract_environment(options) returns:
      # "TEST=(\ \"quoted\"\ ) PATH=/opt/ruby/bin:$PATH"
      def extract_environment(options)
        env = options[:env]
        return "#{env} " if String === env
        Array(env).inject("") do |string, (name, value)|
          value = value.to_s.gsub(/[ "]/) { |m| "\\#{m}" }
          string << "#{name}=#{value} "
        end
      end
  end
end
