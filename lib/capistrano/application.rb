module Capistrano
  class Application < Rake::Application
    def initialize
      super
      @rakefiles = %w{capfile Capfile capfile.rb Capfile.rb}
    end

    def name
      "cap"
    end

    def run
      Rake.application = self
      super
    end

    def sort_options(options)
      not_applicable_to_capistrano = %w(quiet silent verbose)
      options.reject! do |(switch, *)|
        switch =~ /--#{Regexp.union(not_applicable_to_capistrano)}/
      end

      super.push(version, dry_run, roles, hostfilter, print_config_variables)
    end

    def handle_options
      options.rakelib = ["rakelib"]
      options.trace_output = $stderr

      OptionParser.new do |opts|
        opts.banner = "See full documentation at http://capistranorb.com/."
        opts.separator ""
        opts.separator "Install capistrano in a project:"
        opts.separator "    bundle exec cap install [STAGES=qa,staging,production,...]"
        opts.separator ""
        opts.separator "Show available tasks:"
        opts.separator "    bundle exec cap -T"
        opts.separator ""
        opts.separator "Invoke (or simulate invoking) a task:"
        opts.separator "    bundle exec cap [--dry-run] STAGE TASK"
        opts.separator ""
        opts.separator "Advanced options:"

        opts.on_tail("-h", "--help", "-H", "Display this help message.") do
          puts opts
          exit
        end

        standard_rake_options.each { |args| opts.on(*args) }
        opts.environment("RAKEOPT")
      end.parse!
    end

    def top_level_tasks
      if tasks_without_stage_dependency.include?(@top_level_tasks.first)
        @top_level_tasks
      else
        @top_level_tasks.unshift(ensure_stage.to_s)
      end
    end

    def display_error_message(ex)
      unless options.backtrace
        Rake.application.options.suppress_backtrace_pattern = backtrace_pattern if backtrace_pattern
        trace "(Backtrace restricted to imported tasks)"
      end

      super
    end

    def exit_because_of_exception(ex)
      if respond_to?(:deploying?) && deploying?
        exit_deploy_because_of_exception(ex)
      else
        super
      end
    end

    # allows the `cap install` task to load without a capfile
    def find_rakefile_location
      if (location = super).nil?
        [capfile, Dir.pwd]
      else
        location
      end
    end

    private

    def backtrace_pattern
      loc = Rake.application.find_rakefile_location
      return unless loc

      whitelist = (@imported.dup << loc[0]).map { |f| File.absolute_path(f, loc[1]) }
      /^(?!#{whitelist.map { |p| Regexp.quote(p) }.join('|')})/
    end

    def load_imports
      if options.show_tasks && Rake::Task.task_defined?("load:defaults")
        invoke "load:defaults"
        set(:stage, "")
        Dir[deploy_config_path].each { |f| add_import f }
      end

      super
    end

    def capfile
      File.expand_path(File.join(File.dirname(__FILE__), "..", "Capfile"))
    end

    def version
      ["--version", "-V",
       "Display the program version.",
       lambda do |_value|
         puts "Capistrano Version: #{Capistrano::VERSION} (Rake Version: #{Rake::VERSION})"
         exit
       end]
    end

    def dry_run
      ["--dry-run", "-n",
       "Do a dry run without executing actions",
       lambda do |_value|
         Configuration.env.set(:sshkit_backend, SSHKit::Backend::Printer)
       end]
    end

    def roles
      ["--roles ROLES", "-r",
       "Run SSH commands only on hosts matching these roles",
       lambda do |value|
         Configuration.env.add_cmdline_filter(:role, value)
       end]
    end

    def hostfilter
      ["--hosts HOSTS", "-z",
       "Run SSH commands only on matching hosts",
       lambda do |value|
         Configuration.env.add_cmdline_filter(:host, value)
       end]
    end

    def print_config_variables
      ["--print-config-variables", "-p",
       "Display the defined config variables before starting the deployment tasks.",
       lambda do |_value|
         Configuration.env.set(:print_config_variables, true)
       end]
    end
  end
end
