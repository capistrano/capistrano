module Capistrano
  module Deploy
    class RemoteDependency
      attr_reader :configuration
      attr_reader :hosts

      def initialize(configuration)
        @configuration = configuration
        @success = true
      end

      def directory(path, options={})
        @message ||= "`#{path}' is not a directory"
        try("test -d #{path}", options)
        self
      end

      def writable(path, options={})
        @message ||= "`#{path}' is not writable"
        try("test -w #{path}", options)
        self
      end

      def command(command, options={})
        @message ||= "`#{command}' could not be found in the path"
        try("which #{command}", options)
        self
      end

      def gem(name, version, options={})
        @message ||= "gem `#{name}' #{version} could not be found"
        gem_cmd = configuration.fetch(:gem_command, "gem")
        try("#{gem_cmd} specification --version '#{version}' #{name} 2>&1 | awk 'BEGIN { s = 0 } /^name:/ { s = 1; exit }; END { if(s == 0) exit 1 }'", options)
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

      def try(command, options)
        return unless @success # short-circuit evaluation
        configuration.run(command, options) do |ch,stream,out|
          warn "#{ch[:server]}: #{out}" if stream == :err
        end
      rescue Capistrano::CommandError => e
        @success = false
        @hosts = e.hosts.join(', ')
      end
    end
  end
end
