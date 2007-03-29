module Capistrano
  module Deploy
    class RemoteDependency
      attr_reader :configuration
      attr_reader :hosts

      def initialize(configuration)
        @configuration = configuration
        @success = true
      end

      def expect_directory(path)
        @message ||= "`#{path}' is not a directory"
        try("test -d #{path}")
        self
      end

      def expect_writable(path)
        @message ||= "`#{path}' is not writable"
        try("test -w #{path}")
        self
      end

      def expects_in_path(command)
        @message ||= "`#{command}' could not be found in the path"
        try("type -p #{command}")
        self
      end

      def or(message)
        @message = message
        self
      end

      def pass?
        @success
      end

      def message
        s = @message.dup
        s << " (#{@hosts})" if @hosts && @hosts.any?
        s
      end

    private

      def try(command)
        return unless @success # short-circuit evaluation
        configuration.run(command) do |ch,stream,out|
          warn "#{ch[:host]}: #{out}" if stream == :err
        end
      rescue Capistrano::CommandError => e
        @success = false
        @hosts = e.hosts.join(', ')
      end
    end
  end
end