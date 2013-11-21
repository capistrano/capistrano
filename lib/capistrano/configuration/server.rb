require 'set'
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
      end
      alias roles= add_roles

      def add_role(role)
        roles.add role.to_sym
      end

      def has_role?(role)
        roles.include? role.to_sym
      end

      def select?(options)
        selector = Selector.for(options)
        selector.call(self)
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

      def netssh_options_with_options
        @netssh_options ||= netssh_options_without_options.merge( fetch(:ssh_options) || {} )
      end
      alias_method :netssh_options_without_options, :netssh_options
      alias_method :netssh_options, :netssh_options_with_options

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
          @properties[key] = value
        end

        def fetch(key)
          @properties[key]
        end

        def respond_to?(method)
          @properties.has_key?(method)
        end

        def roles
          @roles ||= Set.new
        end

        def method_missing(key, value=nil)
          if value
            set(lvalue(key), value)
          else
            fetch(key)
          end
        end

        private

        def lvalue(key)
          key.to_s.chomp('=').to_sym
        end

      end

      class Selector
        def initialize(options)
          @options = options
        end

        def self.for(options)
          if options.has_key?(:exclude)
            Exclusive
          else
            self
          end.new(options)
        end

        def callable
          if key.respond_to?(:call)
            key
          else
            ->(server) { server.fetch(key) }
          end
        end

        def call(server)
          callable.call(server)
        end

        private
        attr_reader :options

        def key
          options[:filter] || options[:select] || all
        end

        def all
          ->(server) { :all }
        end

        class Exclusive < Selector

          def key
            options[:exclude]
          end

          def call(server)
            !callable.call(server)
          end
        end

      end

    end
  end
end
