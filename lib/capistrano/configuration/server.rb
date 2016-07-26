require "set"
module Capistrano
  class Configuration
    class Server < SSHKit::Host
      extend Forwardable
      def_delegators :properties, :roles, :fetch, :set

      def self.[](host)
        host.is_a?(Server) ? host : new(host)
      end

      def add_roles(roles)
        Array(roles).each { |role| add_role(role) }
        self
      end
      alias roles= add_roles

      def add_role(role)
        roles.add role.to_sym
        self
      end

      def has_role?(role)
        roles.include? role.to_sym
      end

      def select?(options)
        options.each do |k, v|
          callable = v.respond_to?(:call) ? v : ->(server) { server.fetch(v) }
          result = \
            case k
            when :filter, :select
              callable.call(self)
            when :exclude
              !callable.call(self)
            else
              fetch(k) == v
            end
          return false unless result
        end

        true
      end

      def primary
        self if fetch(:primary)
      end

      def with(properties)
        properties.each { |key, value| add_property(key, value) }
        self
      end

      def properties
        @properties ||= Properties.new
      end

      def netssh_options
        @netssh_options ||= super.merge(fetch(:ssh_options) || {})
      end

      def roles_array
        roles.to_a
      end

      def matches?(other)
        hostname == other.hostname && port == other.port
      end

      private

      def add_property(key, value)
        if respond_to?("#{key}=")
          send("#{key}=", value)
        else
          set(key, value)
        end
      end

      class Properties
        def initialize
          @properties = {}
        end

        def set(key, value)
          pval = @properties[key]
          if pval.is_a?(Hash) && value.is_a?(Hash)
            pval.merge!(value)
          elsif pval.is_a?(Set) && value.is_a?(Set)
            pval.merge(value)
          elsif pval.is_a?(Array) && value.is_a?(Array)
            pval.concat value
          else
            @properties[key] = value
          end
        end

        def fetch(key)
          @properties[key]
        end

        def respond_to_missing?(method, _include_all=false)
          @properties.key?(method) || super
        end

        def roles
          @roles ||= Set.new
        end

        def keys
          @properties.keys
        end

        # rubocop:disable Style/MethodMissing
        def method_missing(key, value=nil)
          if value
            set(lvalue(key), value)
          else
            fetch(key)
          end
        end
        # rubocop:enable Style/MethodMissing

        def to_h
          @properties
        end

        private

        def lvalue(key)
          key.to_s.chomp("=").to_sym
        end
      end
    end
  end
end
