require "capistrano/doctor/output_helpers"

module Capistrano
  module Doctor
    # Prints a table of all Capistrano variables and their current values. If
    # there are unrecognized variables, print warnings for them.
    class VariablesDoctor
      # These are keys that have no default values in Capistrano, but are
      # nonetheless expected to be set.
      WHITELIST = [:application, :repo_url, :git_strategy, :hg_strategy, :svn_strategy].freeze
      private_constant :WHITELIST

      include Capistrano::Doctor::OutputHelpers

      def initialize(env=Capistrano::Configuration.env)
        @env = env
      end

      def call
        title("Variables")
        values = inspect_all_values

        table(variables.keys.sort_by(&:to_s)) do |key, row|
          row.yellow if suspicious_keys.include?(key)
          row << key.inspect
          row << values[key]
        end

        puts if suspicious_keys.any?

        suspicious_keys.sort_by(&:to_s).each do |key|
          warning("#{key.inspect} is not a recognized Capistrano setting "\
                  "(#{location(key)})")
        end
      end

      private

      attr_reader :env

      def variables
        env.variables
      end

      def inspect_all_values
        variables.keys.each_with_object({}) do |key, inspected|
          inspected[key] = if env.is_question?(key)
                             "<ask>"
                           else
                             variables.peek(key).inspect
                           end
        end
      end

      def suspicious_keys
        (variables.untrusted_keys & variables.unused_keys) - WHITELIST
      end

      def location(key)
        loc = variables.source_locations(key).first
        loc && loc.sub(/^#{Regexp.quote(Dir.pwd)}/, "").sub(/:in.*/, "")
      end
    end
  end
end
