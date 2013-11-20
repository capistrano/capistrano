module Capistrano
  class Application < Rake::Application

    def initialize
      super
      @name = "cap"
      @rakefiles = %w{capfile Capfile capfile.rb Capfile.rb} << capfile
    end

    def run
      Rake.application = self
      super
    end

    def sort_options(options)
      options.push(version,dry_run,roles)
      super
    end

    def load_rakefile
      @name = 'cap'
      super
    end

    def top_level_tasks
      if tasks_without_stage_dependency.include?(@top_level_tasks.first)
        @top_level_tasks
      else
        @top_level_tasks.unshift(ensure_stage)
      end
    end

    def exit_because_of_exception(ex)
      if deploying?
        exit_deploy_because_of_exception(ex)
      else
        super
      end
    end

    private

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
       "Run only for the roles specified (separate multiple roles with a comma)",
       lambda { |value|
         Configuration.env.set(:filter, :roles => value.split(','))
       }
      ]
    end
  end

end
