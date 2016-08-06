require "capistrano/proc_helpers"

module Capistrano
  class Configuration
    # Holds the variables assigned at Capistrano runtime via `set` and retrieved
    # with `fetch`. Does internal bookkeeping to help identify user mistakes
    # like spelling errors or unused variables that may lead to unexpected
    # behavior.
    class Variables
      CAPISTRANO_LOCATION = File.expand_path("../..", __FILE__).freeze
      IGNORED_LOCATIONS = [
        "#{CAPISTRANO_LOCATION}/configuration/variables.rb:",
        "#{CAPISTRANO_LOCATION}/configuration.rb:",
        "#{CAPISTRANO_LOCATION}/dsl/env.rb:",
        "/dsl.rb:",
        "/forwardable.rb:"
      ].freeze
      private_constant :CAPISTRANO_LOCATION, :IGNORED_LOCATIONS

      include Capistrano::ProcHelpers

      def initialize(values={})
        @trusted_keys = []
        @fetched_keys = []
        @locations = {}
        @values = values
        @trusted = true
      end

      def untrusted!
        @trusted = false
        yield
      ensure
        @trusted = true
      end

      def set(key, value=nil, &block)
        @trusted_keys << key if trusted?
        remember_location(key)
        values[key] = block || value
        trace_set(key)
        values[key]
      end

      def fetch(key, default=nil, &block)
        fetched_keys << key
        peek(key, default, &block)
      end

      # Internal use only.
      def peek(key, default=nil, &block)
        value = fetch_for(key, default, &block)
        while callable_without_parameters?(value)
          value = (values[key] = value.call)
        end
        value
      end

      def fetch_for(key, default, &block)
        block ? values.fetch(key, &block) : values.fetch(key, default)
      end

      def delete(key)
        values.delete(key)
      end

      def trusted_keys
        @trusted_keys.dup
      end

      def untrusted_keys
        keys - @trusted_keys
      end

      def keys
        values.keys
      end

      # Keys that have been set, but which have never been fetched.
      def unused_keys
        keys - fetched_keys
      end

      # Returns an array of source file location(s) where the given key was
      # assigned (i.e. where `set` was called). If the key was never assigned,
      # returns `nil`.
      def source_locations(key)
        locations[key]
      end

      private

      attr_reader :locations, :values, :fetched_keys

      def trusted?
        @trusted
      end

      def remember_location(key)
        location = caller.find do |line|
          IGNORED_LOCATIONS.none? { |i| line.include?(i) }
        end
        (locations[key] ||= []) << location
      end

      def trace_set(key)
        return unless fetch(:print_config_variables, false)
        puts "Config variable set: #{key.inspect} => #{values[key].inspect}"
      end
    end
  end
end
