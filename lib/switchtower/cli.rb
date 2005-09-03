require 'optparse'
require 'switchtower'

module SwitchTower
  class CLI
    def self.execute!
      new.execute!
    end

    begin
      if !defined?(USE_TERMIOS) || USE_TERMIOS
        require 'termios'
      else
        raise LoadError
      end

      # Enable or disable stdin echoing to the terminal.
      def echo(enable)
        term = Termios::getattr(STDIN)

        if enable
          term.c_lflag |= (Termios::ECHO | Termios::ICANON)
        else
          term.c_lflag &= ~Termios::ECHO
        end

        Termios::setattr(STDIN, Termios::TCSANOW, term)
      end
    rescue LoadError
      def echo(enable)
      end
    end

    attr_reader :options
    attr_reader :args

    def initialize(args = ARGV)
      @args = args
      @options = { :verbose => 0, :recipes => [], :actions => [], :vars => {} }

      OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] [args]"

        opts.separator ""
        opts.separator "Recipe Options -----------------------"
        opts.separator ""

        opts.on("-a", "--action ACTION",
          "An action to execute. Multiple actions may",
          "be specified, and are loaded in the given order."
        ) { |value| @options[:actions] << value }

        opts.on("-p", "--password PASSWORD",
          "The password to use when connecting.",
          "(Default: prompt for password)"
        ) { |value| @options[:password] = value }

        opts.on("-r", "--recipe RECIPE",
          "A recipe file to load. Multiple recipes may",
          "be specified, and are loaded in the given order."
        ) { |value| @options[:recipes] << value }

        opts.on("-s", "--set NAME=VALUE",
          "Specify a variable and it's value to set. This",
          "will be set after loading all recipe files."
        ) do |pair|
          name, value = pair.split(/=/)
          @options[:vars][name.to_sym] = value
        end

        opts.separator ""
        opts.separator "Framework Integration Options --------"
        opts.separator ""

        opts.on("-A", "--apply-to DIRECTORY",
          "Create a minimal set of scripts and recipes to use",
          "switchtower with the application at the given",
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

        opts.on("-v", "--verbose",
          "Specify the verbosity of the output.",
          "May be given multiple times. (Default: silent)"
        ) { @options[:verbose] += 1 }

        opts.on("-V", "--version",
          "Display the version info for this utility"
        ) do
          require 'switchtower/version'
          puts "SwitchTower v#{SwitchTower::Version::STRING}"
          exit
        end

        opts.separator ""
        opts.separator <<DETAIL.split(/\n/)
You can use the --apply-to switch to generate a minimal set of switchtower
scripts and recipes for an application. Just specify the path to the application
as the argument to --apply-to, like this:

  switchtower --apply-to ~/projects/myapp

You'll wind up with a sample deployment recipe in config/deploy.rb, some new
rake tasks in config/tasks, and a switchtower script in your script directory.

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

      unless @options.has_key?(:password)
        @options[:password] = Proc.new do
          sync = STDOUT.sync
          begin
            echo false
            STDOUT.sync = true
            print "Password: "
            STDIN.gets.chomp
          ensure
            echo true
            STDOUT.sync = sync
            puts
          end
        end
      end
    end

    def execute!
      if !@options[:recipes].empty?
        execute_recipes!
      elsif @options[:apply_to]
        execute_apply_to!
      end
    end

    private

      def execute_recipes!
        config = SwitchTower::Configuration.new
        config.logger.level = options[:verbose]
        config.set :password, options[:password]
        config.set :pretend, options[:pretend]

        config.load "standard" # load the standard recipe definition

        options[:recipes].each { |recipe| config.load(recipe) }
        options[:vars].each { |name, value| config.set(name, value) }

        actor = config.actor
        options[:actions].each { |action| actor.send action }
      end

      def execute_apply_to!
        require 'switchtower/generators/rails/loader'
        Generators::RailsLoader.load! @options
      end

      APPLY_TO_OPTIONS = [:apply_to]
      RECIPE_OPTIONS   = [:password]

      def check_options!
        apply_to_given = !(@options.keys & APPLY_TO_OPTIONS).empty?
        recipe_given   = !(@options.keys & RECIPE_OPTIONS).empty? ||
                         !@options[:recipes].empty? ||
                         !@options[:actions].empty?

        if apply_to_given && recipe_given
          abort "You cannot specify both recipe options and framework integration options."
        elsif !apply_to_given
          abort "You must specify at least one recipe" if @options[:recipes].empty?
          abort "You must specify at least one action" if @options[:actions].empty?
        else
          @options[:application] = args.shift
          @options[:recipe_file] = args.shift
        end
      end
  end
end
