require 'capistrano/errors'
require 'capistrano/processable'

module Capistrano

  # This class encapsulates a single command to be executed on a set of remote
  # machines, in parallel.
  class Command
    include Processable

    class Tree
      attr_reader :branches

      class Branch
        attr_accessor :command, :callback

        def initialize(command, callback)
          @command = command.strip.gsub(/\r?\n/, "\\\n")
          @callback = callback || Capistrano::Configuration.default_io_proc
          @skip = false
        end

        def skip?
          @skip
        end

        def skip!
          @skip = true
        end

        def match(server)
          true
        end

        def to_s
          command.inspect
        end
      end

      class PatternBranch < Branch
        attr_accessor :pattern

        def initialize(pattern, command, callback)
          @pattern = pattern
          super(command, callback)
        end

        def match(server)
          pattern === server.host
        end

        def to_s
          "#{pattern.inspect} :: #{command.inspect}"
        end
      end

      def initialize
        @branches = []
        yield self if block_given?
      end

      def if(pattern, command, &block)
        branches << PatternBranch.new(pattern, command, block)
      end

      def else(command, &block)
        branches << Branch.new(command, block)
      end

      def branch_for(server)
        branches.detect { |branch| branch.match(server) }
      end
    end

    attr_reader :tree, :sessions, :options

    def self.process(tree, sessions, options={})
      new(tree, sessions, options).process!
    end

    # Instantiates a new command object. The +command+ must be a string
    # containing the command to execute. +sessions+ is an array of Net::SSH
    # session instances, and +options+ must be a hash containing any of the
    # following keys:
    #
    # * +logger+: (optional), a Capistrano::Logger instance
    # * +data+: (optional), a string to be sent to the command via it's stdin
    # * +env+: (optional), a string or hash to be interpreted as environment
    #   variables that should be defined for this command invocation.
    def initialize(tree, sessions, options={})
      @tree = tree
      @sessions = sessions
      @options = options
      @channels = open_channels
    end

    # Processes the command in parallel on all specified hosts. If the command
    # fails (non-zero return code) on any of the hosts, this will raise a
    # Capistrano::CommandError.
    def process!
      loop do
        break unless process_iteration { @channels.any? { |ch| !ch[:closed] } }
      end

      logger.trace "command finished" if logger

      if (failed = @channels.select { |ch| ch[:status] != 0 }).any?
        hosts = failed.map { |ch| ch[:server] }
        error = CommandError.new("command #{command.inspect} failed on #{hosts.join(',')}")
        error.hosts = hosts
        raise error
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

      def logger
        options[:logger]
      end

      def open_channels
        sessions.map do |session|
          server = session.xserver
          branch = tree.branch_for(server)
          next if branch.skip?

          session.open_channel do |channel|
            channel[:server] = server
            channel[:host] = server.host
            channel[:options] = options
            channel[:branch] = branch

            request_pty_if_necessary(channel) do |ch, success|
              if success
                logger.trace "executing command", ch[:server] if logger
                cmd = replace_placeholders(channel[:branch].command, ch)

                if options[:shell] == false
                  shell = nil
                else
                  shell = "#{options[:shell] || "sh"} -c"
                  cmd = cmd.gsub(/[$\\`"]/) { |m| "\\#{m}" }
                  cmd = "\"#{cmd}\""
                end

                command_line = [environment, shell, cmd].compact.join(" ")

                ch.exec(command_line)
                ch.send_data(options[:data]) if options[:data]
              else
                # just log it, don't actually raise an exception, since the
                # process method will see that the status is not zero and will
                # raise an exception then.
                logger.important "could not open channel", ch[:server] if logger
                ch.close
              end
            end

            channel.on_data do |ch, data|
              ch[:branch].callback[ch, :out, data]
            end

            channel.on_extended_data do |ch, type, data|
              ch[:branch].callback[ch, :err, data]
            end

            channel.on_request("exit-status") do |ch, data|
              ch[:status] = data.read_long
            end

            channel.on_close do |ch|
              ch[:closed] = true
            end
          end
        end.compact
      end

      def request_pty_if_necessary(channel)
        if options[:pty]
          channel.request_pty do |ch, success|
            yield ch, success
          end
        else
          yield channel, true
        end
      end

      def replace_placeholders(command, channel)
        command.gsub(/\$CAPISTRANO:HOST\$/, channel[:host])
      end

      # prepare a space-separated sequence of variables assignments
      # intended to be prepended to a command, so the shell sets
      # the environment before running the command.
      # i.e.: options[:env] = {'PATH' => '/opt/ruby/bin:$PATH',
      #                        'TEST' => '( "quoted" )'}
      # environment returns:
      # "env TEST=(\ \"quoted\"\ ) PATH=/opt/ruby/bin:$PATH"
      def environment
        return if options[:env].nil? || options[:env].empty?
        @environment ||= if String === options[:env]
            "env #{options[:env]}"
          else
            options[:env].inject("env") do |string, (name, value)|
              value = value.to_s.gsub(/[ "]/) { |m| "\\#{m}" }
              string << " #{name}=#{value}"
            end
          end
      end
  end
end
