require "capistrano/doctor/output_helpers"

module Capistrano
  module Doctor
    class EnvironmentDoctor
      include Capistrano::Doctor::OutputHelpers

      def call
        title("Environment")
        puts <<-OUT.gsub(/^\s+/, "")
          Ruby     #{RUBY_DESCRIPTION}
          Rubygems #{Gem::VERSION}
          Bundler  #{defined?(Bundler::VERSION) ? Bundler::VERSION : 'N/A'}
          Command  #{$PROGRAM_NAME} #{ARGV.join(' ')}
        OUT
      end
    end
  end
end
