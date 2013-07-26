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
      options.push(version)
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
        @top_level_tasks.unshift('deploy:ensure_stage')
      end
    end

    private

    # allows the `cap install` task to load without a capfile
    def capfile
      File.expand_path(File.join(File.dirname(__FILE__),'..','Capfile'))
    end

    def tasks_without_stage_dependency
      defined_stages = Dir['config/deploy/*.rb'].map { |f| File.basename(f, '.rb') }
      defined_stages + default_tasks
    end

    def default_tasks
      %w{install}
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
  end

end
