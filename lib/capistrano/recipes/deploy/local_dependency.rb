require 'capistrano/recipes/deploy/dependency'

module Capistrano
  module Deploy
    class LocalDependency < Dependency
      def initialize(configuration)
        super(configuration)
      end

      def command(command)
        @message ||= "`#{command}' could not be found in the path on the local host"
        @success = find_in_path(command)
        self
      end

      def file(path)
        @message ||= "`#{path}' is not a file"
        @success = false unless Dir.exists?(path)
        self
      end

      def directory(path)
        @message ||= "`#{path}' is not a directory"
        @success = File.directory?(path)
        self
      end

      def writeable(path)
        @message ||= "`#{path}' is not writable"
        @success = File.writeable?(path)
        self
      end

      def file(path)
        @message ||= "`#{path}' is not a file"
        @success = File.file?(path)
        self
      end

    private

      def try!(command, options)
        @success = system(command, options)
      end

      # Searches the path, looking for the given utility. If an executable
      # file is found that matches the parameter, this returns true.
      def find_in_path(utility)
        path = (ENV['PATH'] || "").split(File::PATH_SEPARATOR)
        suffixes = self.class.on_windows? ? self.class.windows_executable_extensions : [""]

        path.each do |dir|
          suffixes.each do |sfx|
            file = File.join(dir, utility + sfx)
            return true if File.executable?(file)
          end
        end

        false
      end

      def self.on_windows?
        RUBY_PLATFORM =~ /mswin|mingw/
      end

      def self.windows_executable_extensions
        %w(.exe .bat .com .cmd)
      end
    end
  end
end
