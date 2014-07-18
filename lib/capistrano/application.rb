module Capistrano
  class Application < Rake::Application

    def self.reset_loaded_rakefiles!
      @loaded_rakefile = []
    end

    def self.loaded_rakefiles
      @loaded_rakefile ||= []
    end

    def self.rakefile_loaded?(file_path)
      loaded_rakefiles.include? file_path
    end

    def self.add_loaded_rakefiles(file_path)
      loaded_rakefiles << file_path
    end

    def self.load_rakefile_once(file, load_provider=Kernel)
      file_path = File.expand_path(file)
      unless rakefile_loaded?(file_path)
        load_provider.load file_path
        add_loaded_rakefiles(file_path)
      end
    end

    def initialize
      super
      @rakefiles = %w{capfile Capfile capfile.rb Capfile.rb} << capfile
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

      options.push(version, roles, dry_run, hostfilter)
      super
    end

    def handle_options
      options.rakelib = ['rakelib']
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
        opts.environment('RAKEOPT')
      end.parse!
    end


    def top_level_tasks
      if tasks_without_stage_dependency.include?(@top_level_tasks.first)
        @top_level_tasks
      else
        @top_level_tasks.unshift(ensure_stage.to_s)
      end
    end

    def exit_because_of_exception(ex)
      if respond_to?(:deploying?) && deploying?
        exit_deploy_because_of_exception(ex)
      else
        super
      end
    end

    private

    def load_imports
      if options.show_tasks
        invoke 'load:defaults'
        set(:stage, '')
        Dir[deploy_config_path, stage_definitions].each { |f| add_import f }
      end

      super
    end

    # allows the `cap install` task to load without a capfile
    def capfile
      File.expand_path(File.join(File.dirname(__FILE__),'..','Capfile'))
    end

    def version
      ['--version', '-V',
       "Display the program version.",
       lambda { |value|
         puts "Capistrano Version: #{Capistrano::VERSION} (Rake Version: #{RAKEVERSION})"
         exit
       }
      ]
    end

    def dry_run
      ['--dry-run', '-n',
       "Do a dry run without executing actions",
       lambda { |value|
         Configuration.env.set(:sshkit_backend, SSHKit::Backend::Printer)
       }
      ]
    end

    def roles
      ['--roles ROLES', '-r',
       "Filter command to only apply to these roles (separate multiple roles with a comma)",
       lambda { |value|
         Configuration.env.set(:filter, roles: value.split(","))
       }
      ]
    end

    def hostfilter
      ['--hosts HOSTS', '-z',
       "Filter command to only apply to these hosts (separate multiple hosts with a comma)",
       lambda { |value|
         Configuration.env.set(:filter, hosts: value.split(","))
       }
      ]
    end

  end

end
