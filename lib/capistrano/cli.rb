require 'optparse'
require 'capistrano'

module Capistrano
  # The CLI class encapsulates the behavior of capistrano when it is invoked
  # as a command-line utility. This allows other programs to embed ST and
  # preserve it's command-line semantics.
  class CLI
    # Invoke capistrano using the ARGV array as the option parameters. This
    # is what the command-line capistrano utility does.
    def self.execute!
      new.execute!
    end

    # The following determines whether or not echo-suppression is available.
    # This requires the termios library to be installed (which, unfortunately,
    # is not available for Windows).
    begin
      if !defined?(USE_TERMIOS) || USE_TERMIOS
        require 'termios'
      else
        raise LoadError
      end

      # Enable or disable stdin echoing to the terminal.
      def self.echo(enable)
        term = Termios::getattr(STDIN)

        if enable
          term.c_lflag |= (Termios::ECHO | Termios::ICANON)
        else
          term.c_lflag &= ~Termios::ECHO
        end

        Termios::setattr(STDIN, Termios::TCSANOW, term)
      end
    rescue LoadError
      def self.echo(enable)
      end
    end

    # execute the associated block with echo-suppression enabled. Note that
    # if termios is not available, echo suppression will not be available
    # either.
    def self.with_echo
      echo(false)
      yield
    ensure
      echo(true)
    end

    # Prompt for a password using echo suppression.
    def self.password_prompt(prompt="Password: ")
      sync = STDOUT.sync
      begin
        with_echo do
          STDOUT.sync = true
          print(prompt)
          STDIN.gets.chomp
        end
      ensure
        STDOUT.sync = sync
        puts
      end
    end

    # The array of (unparsed) command-line options
    attr_reader :args

    # The hash of (parsed) command-line options
    attr_reader :options

    # Create a new CLI instance using the given array of command-line parameters
    # to initialize it. By default, +ARGV+ is used, but you can specify a
    # different set of parameters (such as when embedded ST in a program):
    #
    #   require 'capistrano/cli'
    #   Capistrano::CLI.new(%w(-vvvv -r config/deploy -a update_code)).execute!
    #
    # Note that you can also embed ST directly by creating a new Configuration
    # instance and setting it up, but you'll often wind up duplicating logic
    # defined in the CLI class. The above snippet, redone using the Configuration
    # class directly, would look like:
    #
    #   require 'capistrano'
    #   require 'capistrano/cli'
    #   config = Capistrano::Configuration.new
    #   config.logger_level = Capistrano::Logger::TRACE
    #   config.set(:password) { Capistrano::CLI.password_prompt }
    #   config.load "standard", "config/deploy"
    #   config.actor.update_code
    #
    # There may be times that you want/need the additional control offered by
    # manipulating the Configuration directly, but generally interfacing with
    # the CLI class is recommended.
    def initialize(args = ARGV)
      @args = args
      @options = { :recipes => [], :actions => [], :vars => {},
        :pre_vars => {} }

      OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] [args]"

        opts.separator ""
        opts.separator "Recipe Options -----------------------"
        opts.separator ""

        opts.on("-a", "--action ACTION",
          "An action to execute. Multiple actions may",
          "be specified, and are loaded in the given order."
        ) { |value| @options[:actions] << value }

        opts.on("-p", "--password [PASSWORD]",
          "The password to use when connecting. If the switch",
          "is given without a password, the password will be",
          "prompted for immediately. (Default: prompt for password",
          "the first time it is needed.)"
        ) { |value| @options[:password] = value }

        opts.on("-r", "--recipe RECIPE",
          "A recipe file to load. Multiple recipes may",
          "be specified, and are loaded in the given order."
        ) { |value| @options[:recipes] << value }

        opts.on("-s", "--set NAME=VALUE",
          "Specify a variable and it's value to set. This",
          "will be set after loading all recipe files."
        ) do |pair|
          name, value = pair.split(/=/, 2)
          @options[:vars][name.to_sym] = value
        end

        opts.on("-S", "--set-before NAME=VALUE",
          "Specify a variable and it's value to set. This",
          "will be set BEFORE loading all recipe files."
        ) do |pair|
          name, value = pair.split(/=/, 2)
          @options[:pre_vars][name.to_sym] = value
        end

        opts.separator ""
        opts.separator "Framework Integration Options --------"
        opts.separator ""

        opts.on("-A", "--apply-to DIRECTORY",
          "Create a minimal set of scripts and recipes to use",
          "capistrano with the application at the given",
          "directory. (Currently only works with Rails apps.)"
        ) { |value| @options[:apply_to] = value }

        opts.separator ""
        opts.separator "Miscellaneous Options ----------------"
        opts.separator ""

        opts.on("-h", "--help", "Display this help message") do
          puts opts
          exit
        end

        opts.on("-P", "--[no-]pretend",
          "Run the task(s), but don't actually connect to or",
          "execute anything on the servers. (For various reasons",
          "this will not necessarily be an accurate depiction",
          "of the work that will actually be performed.",
          "Default: don't pretend.)"
        ) { |value| @options[:pretend] = value }

        opts.on("-q", "--quiet",
          "Make the output as quiet as possible (the default)"
        ) { @options[:verbose] = 0 }

        opts.on("-v", "--verbose",
          "Specify the verbosity of the output.",
          "May be given multiple times. (Default: silent)"
        ) { @options[:verbose] ||= 0; @options[:verbose] += 1 }

        opts.on("-V", "--version",
          "Display the version info for this utility"
        ) do
          require 'capistrano/version'
          puts "Capistrano v#{Capistrano::Version::STRING}"
          exit
        end

        opts.separator ""
        opts.separator <<-DETAIL.split(/\n/)
You can use the --apply-to switch to generate a minimal set of capistrano
scripts and recipes for an application. Just specify the path to the application
as the argument to --apply-to, like this:

  capistrano --apply-to ~/projects/myapp

You'll wind up with a sample deployment recipe in config/deploy.rb, some new
rake tasks in config/tasks, and a capistrano script in your script directory.

(Currently, --apply-to only works with Rails applications.)
DETAIL

        if args.empty?
          puts opts
          exit
        else
          opts.parse!(args)
        end
      end

      check_options!

      password_proc = Proc.new { self.class.password_prompt }

      if !@options.has_key?(:password)
        @options[:password] = password_proc
      elsif !@options[:password]
        @options[:password] = password_proc.call
      end
    end

    # Beginning running Capistrano based on the configured options.
    def execute!
      if !@options[:recipes].empty?
        execute_recipes!
      elsif @options[:apply_to]
        execute_apply_to!
      end
    end

    private

      # Load the recipes specified by the options, and execute the actions
      # specified.
      def execute_recipes!
        config = Capistrano::Configuration.new
        config.logger.level = options[:verbose]
        config.set :password, options[:password]
        config.set :pretend, options[:pretend]

        options[:pre_vars].each { |name, value| config.set(name, value) }

        # load the standard recipe definition
        config.load "standard"

        options[:recipes].each { |recipe| config.load(recipe) }
        options[:vars].each { |name, value| config.set(name, value) }

        actor = config.actor
        options[:actions].each { |action| actor.send action }
      end

      # Load the Rails generator and apply it to the specified directory.
      def execute_apply_to!
        require 'capistrano/generators/rails/loader'
        Generators::RailsLoader.load! @options
      end

      APPLY_TO_OPTIONS = [:apply_to]
      RECIPE_OPTIONS   = [:password]
      DEFAULT_RECIPES  = %w(Capfile capfile config/deploy.rb)

      # A sanity check to ensure that a valid operation is specified.
      def check_options!
        # if no verbosity has been specified, be verbose
        @options[:verbose] = 3 if !@options.has_key?(:verbose)

        apply_to_given = !(@options.keys & APPLY_TO_OPTIONS).empty?
        recipe_given   = !(@options.keys & RECIPE_OPTIONS).empty? ||
                         !@options[:recipes].empty? ||
                         !@options[:actions].empty?

        if apply_to_given && recipe_given
          abort "You cannot specify both recipe options and framework integration options."
        elsif !apply_to_given
          look_for_default_recipe_file! if @options[:recipes].empty?
          look_for_raw_actions!
          abort "You must specify at least one recipe" if @options[:recipes].empty?
          abort "You must specify at least one action" if @options[:actions].empty?
        else
          @options[:application] = args.shift
          @options[:recipe_file] = args.shift
        end
      end

      def look_for_default_recipe_file!
        DEFAULT_RECIPES.each do |file|
          if File.exist?(file)
            @options[:recipes] << file
            break
          end
        end
      end

      def look_for_raw_actions!
        @options[:actions].concat(@args)
      end
  end
end
