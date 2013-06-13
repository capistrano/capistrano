module Capistrano
  class Application < Rake::Application

    def initialize
      super
      @rakefiles = %w{capfile Capfile capfile.rb Capfile.rb} << capfile
    end

    def run
      Rake.application = self
      super
    end

    def standard_rake_options
      Rake::Application.new.standard_rake_options.tap do |sra|
        sra[sra.index { |opt| opt[0] == "--version" }][3] = lambda do |value|
          puts "Capistrano Version: #{Capistrano::VERSION} (Rake Version: #{RAKEVERSION})"
        end
      end
    end

    def load_rakefile
      @name = 'cap'
      super
    end

    private

    # allows the `cap install` task to load without a capfile
    def capfile
      File.expand_path(File.join(File.dirname(__FILE__),'..','Capfile'))
    end
  end

end
