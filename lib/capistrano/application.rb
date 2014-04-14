module Capistrano
  class Application < Rake::Application

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
      options.push(version, roles, dry_run, hostfilter)
      super
    end

    def top_level_tasks
      if tasks_without_stage_dependency.include?(@top_level_tasks.first)
        @top_level_tasks
      else
        @top_level_tasks.unshift(ensure_stage.to_s)
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
