module Capistrano
  class Env

    def initialize
      @env = {}
      yield self if block_given?
    end

    class << self
      def configure(&block)
        @env ||= new &block
      end

      def configuration
        @env
      end
    end

    def method_missing(key, value=nil)
      return set(key, value) if value
      fetch(key)
    end

    def set(key, value)
      env[key] = value
    end

    def fetch(value)
      env[value]
    end

    def respond_to?(method)
      env.has_key?(method)
    end

    def role(title, servers)
      hosts = servers.map { |s| SSHKit::Host.new(s) }
      roles.merge!(title => hosts)
    end

    def roles
      @roles ||= {}
    end

    private
    attr_reader :env
  end
end
