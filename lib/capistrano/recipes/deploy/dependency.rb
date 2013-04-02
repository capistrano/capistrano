module Capistrano
  module Deploy
    class Dependency
      attr_reader :configuration
      attr_reader :success
      attr_reader :message

      def initialize(configuration)
        @configuration = configuration
        @success = true
      end

      def gem(name, version, options={})
        @message ||= "gem `#{name}' #{version} could not be found"
        gem_cmd = configuration.fetch(:gem_command, "gem")
        try("#{gem_cmd} specification --version '#{version}' #{name} 2>&1 | awk 'BEGIN { s = 0 } /^name:/ { s = 1; exit }; END { if(s == 0) exit 1 }'", options)
        self
      end

      def deb(name, version, options={})
        @message ||= "package `#{name}' #{version} could not be found"
        try("dpkg -s #{name} | grep '^Version: #{version}'", options)
        self
      end

      def rpm(name, version, options={})
        @message ||= "package `#{name}' #{version} could not be found"
        try("rpm -q #{name} | grep '#{version}'", options)
        self
      end

      def or(message)
        @message = message
        self
      end

      def pass?
        @success
      end

      private

      def try(command, options)
        return unless @success # short-circuit evaluation
        try!(command, options)
      end
    end
  end
end
