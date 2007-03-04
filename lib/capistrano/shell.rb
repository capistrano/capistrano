require 'thread'

module Capistrano
  # The Capistrano::Shell class is the guts of the "shell" task. It implements
  # an interactive REPL interface that users can employ to execute tasks and
  # commands. It makes for a GREAT way to monitor systems, and perform quick
  # maintenance on one or more machines.
  class Shell
    # The actor instance employed by this shell
    attr_reader :actor

    # Instantiate a new shell and begin executing it immediately.
    def self.run(actor)
      new(actor).run!
    end

    # Instantiate a new shell
    def initialize(actor)
      @actor = actor
    end

    # Start the shell running. This method will block until the shell
    # terminates.
    def run!
      setup

      puts <<-INTRO
====================================================================
Welcome to the interactive Capistrano shell! This is an experimental
feature, and is liable to change in future releases.
--------------------------------------------------------------------
INTRO

      loop do
        command = @reader.readline("cap> ", true)

        case command ? command.strip : command
          when "" then next
          when "help"  then help
          when nil, "quit", "exit" then
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

      # A Readline replacement for platforms where readline is either
      # unavailable, or has not been installed.
      class ReadlineFallback
        def self.readline(prompt, *args)
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
        needing_connections = servers - actor.sessions.keys
        unless needing_connections.empty?
          puts "[establishing connection(s) to #{needing_connections.join(', ')}]"
          actor.send(:establish_connections, servers)
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
          servers = connect(actor.current_task)
          exec_command(command, servers)
        end
      ensure
        STDOUT.flush
      end

      # Given an array of task names, invoke them in sequence.
      def exec_tasks(list)
        list.each do |task_name|
          task = task_name.to_sym
          connect(actor.tasks[task])
          actor.send(task)
        end
      end

      # Execute a command on the given list of servers.
      def exec_command(command, servers)
        processor = Proc.new do |ch, stream, out|
          # TODO: more robust prompt detection
          out.each do |line|
            if stream == :out
              if out =~ /Password:\s*/i
                ch.send_data "#{actor.password}\n"
              else
                puts "[#{ch[:host]}] #{line.chomp}"
              end
            elsif stream == :err
              puts "[#{ch[:host]} ERR] #{line.chomp}"
            end
          end
        end

        cmd = Command.new(servers, command, processor, {}, actor)
        previous = trap("INT") { cmd.stop! }
        cmd.process! rescue nil
        trap("INT", previous)
      end

      # Prepare every little thing for the shell. Starts the background
      # thread and generally gets things ready for the REPL.
      def setup
        begin
          require 'readline'
          @reader = Readline
        rescue LoadError
          @reader = ReadlineFallback
        end

        @mutex = Mutex.new
        @bgthread = Thread.new do
            loop do
              ready = actor.sessions.values.select { |sess| sess.connection.reader_ready? }
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
            actor.logger.level = value.to_i
          else
            puts "unknown setting #{value.inspect}"
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
