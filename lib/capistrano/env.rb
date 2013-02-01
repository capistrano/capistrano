module Capistrano
  class Env

    def initialize
      @env = {}
      yield self if block_given?
    end

    class << self
      def configure(&block)
        @env = new &block
      end

      def configuration
        @env
      end
    end

    def method_missing(key, value=nil)
      return set(key, value) if value
      get(key)
    end

    def set(key, value)
      @env[key] = value
    end

    def get(value)
      @env[value]
    end

    def respond_to?(method)
      @env.has_key?(method)
    end

    def role(title, servers)
      roles.merge!(title => servers)
    end

    def roles
      @roles ||= {}
    end
  end
end
