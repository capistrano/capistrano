require 'thread'

module Capistrano
  # The Capistrano::Shell class is the guts of the "shell" task. It implements
  # an interactive REPL interface that users can employ to execute tasks and
  # commands. It makes for a GREAT way to monitor systems, and perform quick
  # maintenance on one or more machines.
  class Shell
    # The configuration instance employed by this shell
    attr_reader :configuration

    # Instantiate a new shell and begin executing it immediately.
    def self.run(config)
      new(config).run!
    end

    # Instantiate a new shell
    def initialize(config)
      @configuration = config
    end

    # Start the shell running. This method will block until the shell
    # terminates.
    def run!
      setup

      puts <<-INTRO
====================================================================
Welcome to the interactive Capistrano shell! This is an experimental
feature, and is liable to change in future releases. Type 'help' for
a summary of how to use the shell.
--------------------------------------------------------------------
INTRO

      loop do
        command = read_line

        case command
          when "?", "help" then help
          when "quit", "exit" then
            puts if command.nil?
            puts "exiting"
            break
          when /^set -(\w)\s*(\S+)/
            set_option($1, $2)
          when /^(?:(with|on)\s*(\S+))?\s*(\S.*)?/i
            process_command($1, $2, $3)
          else
            raise "eh?"
        end
      end

      @bgthread.kill
    end

    private

      def read_line
        loop do
          command = reader.readline("cap> ")

          if command.nil?
            command = "exit"
            puts(command)
          else
            command.strip!
          end

          unless command.empty?
            reader::HISTORY << command
            return command
          end
        end
      end

      # A Readline replacement for platforms where readline is either
      # unavailable, or has not been installed.
      class ReadlineFallback
        HISTORY = []

        def self.readline(prompt)
          STDOUT.print(prompt)
          STDOUT.flush
          STDIN.gets
        end
      end

      # Display a verbose help message.
      def help
        puts <<-HELP
Welcome to the interactive Capistrano shell! To quit, just type quit,
or exit. Or press ctrl-D. This shell is still experimental, so expect
it to change (or even disappear!) in future releases.

To execute a command on all servers, just type it directly, like:

  cap> echo ping

To execute a command on a specific set of servers, specify an 'on' clause.
Note that if you specify more than one host name, they must be comma-
delimited, with NO SPACES between them.

  cap> on app1.foo.com,app2.foo.com echo ping

To execute a command on all servers matching a set of roles:

  cap> with app,db echo ping

To execute a Capistrano task, prefix the name with a bang:

  cap> !deploy

You can specify multiple tasks to execute, separated by spaces:

  cap> !update_code symlink

And, lastly, you can specify 'on' or 'with' with tasks:

  cap> on app6.foo.com !setup

Enjoy!  
HELP
      end

      # Determine which servers the given task requires a connection to, and
      # establish connections to them if necessary. Return the list of
      # servers (names).
      def connect(task)
        servers = task.servers(:refresh)
        needing_connections = servers.reject { |s| configuration.sessions.key?(s.host) }
        unless needing_connections.empty?
          puts "[establishing connection(s) to #{needing_connections.map { |s| s.host }.join(', ')}]"
          configuration.establish_connections_to(needing_connections)
        end
        servers
      end

      # Execute the given command. If the command is prefixed by an exclamation
      # mark, it is assumed to refer to another capistrano task, which will
      # be invoked. Otherwise, it is executed as a command on all associated
      # servers.
      def exec(command)
        if command[0] == ?!
          exec_tasks(command[1..-1].split)
        else
          servers = connect(configuration.current_task)
          exec_command(command, servers)
        end
      ensure
        STDOUT.flush
      end

      # Given an array of task names, invoke them in sequence.
      def exec_tasks(list)
        list.each do |task_name|
          task = configuration.find_task(task_name)
          raise Capistrano::NoSuchTaskError, "no such task `#{task_name}'" unless task
          connect(task)
          configuration.execute_task(task)
        end
      rescue Capistrano::NoSuchTaskError => error
        warn "error: #{error.message}"
      end

      # Execute a command on the given list of servers.
      def exec_command(command, servers)
        processor = Proc.new do |ch, stream, out|
          # TODO: more robust prompt detection
          out.each do |line|
            if stream == :out
              if out =~ /Password:\s*/i
                ch.send_data "#{configuration[:password]}\n"
              else
                puts "[#{ch[:host]}] #{line.chomp}"
              end
            elsif stream == :err
              puts "[#{ch[:host]} ERR] #{line.chomp}"
            end
          end
        end

        previous = trap("INT") { cmd.stop! }
        sessions = servers.map { |server| configuration.sessions[server.host] }
        Command.process(command, sessions, :logger => configuration.logger, &Capistrano::Configuration.default_io_proc)
      rescue Capistrano::Error => error
        warn "error: #{error.message}"
      ensure
        trap("INT", previous)
      end

      def reader
        @reader ||= begin
          require 'readline'
          Readline
        rescue LoadError
          ReadlineFallback
        end
      end

      # Prepare every little thing for the shell. Starts the background
      # thread and generally gets things ready for the REPL.
      def setup
        configuration.logger.level = Capistrano::Logger::INFO

        @mutex = Mutex.new
        @bgthread = Thread.new do
            loop do
              ready = configuration.sessions.values.select { |sess| sess.connection.reader_ready? }
              if ready.empty?
                sleep 0.1
              else
                @mutex.synchronize do
                  ready.each { |session| session.connection.process(true) }
                end
              end
            end
          end
      end

      # Set the given option to +value+.
      def set_option(opt, value)
        case opt
          when "v" then
            puts "setting log verbosity to #{value.to_i}"
            configuration.logger.level = value.to_i
          when "o" then
            case value
            when "vi" then
              puts "using vi edit mode"
              reader.vi_editing_mode
            when "emacs" then
              puts "using emacs edit mode"
              reader.emacs_editing_mode
            else
              puts "unknown -o option #{value.inspect}"
            end
          else
            puts "unknown setting #{opt.inspect}"
        end
      end

      # Process a command. Interprets the scope_type (must be nil, "with", or
      # "on") and the command. If no command is given, then the scope is made
      # effective for all subsequent commands. If the scope value is "all",
      # then the scope is unrestricted.
      def process_command(scope_type, scope_value, command)
        env_var = case scope_type
            when "with" then "ROLES"
            when "on"   then "HOSTS"
          end

        old_var, ENV[env_var] = ENV[env_var], (scope_value == "all" ? nil : scope_value) if env_var
        if command
          begin
            @mutex.synchronize { exec(command) }
          ensure
            ENV[env_var] = old_var if env_var
          end
        else
          puts "scoping #{scope_type} #{scope_value}"
        end
      end
  end
end
