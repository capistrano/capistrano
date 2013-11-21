require_relative 'configuration/question'
require_relative 'configuration/servers'
require_relative 'configuration/server'

module Capistrano
  class Configuration

    class << self
      def env
        @env ||= new
      end

      def reset!
        @env = new
      end
    end

    def ask(key, default=nil)
      question = Question.new(self, key, default)
      set(key, question)
    end

    def set(key, value)
      config[key] = value
    end

    def delete(key)
      config.delete(key)
    end

    def fetch(key, default=nil, &block)
      value = fetch_for(key, default, &block)
      if value.respond_to?(:call)
        set(key, value.call)
      else
        value
      end
    end

    def role(name, hosts, options={})
      if name == :all
        raise ArgumentError.new("#{name} reserved name for role. Please choose another name")
      end

      servers.add_role(name, hosts, options)
    end

    def server(name, properties={})
      servers.add_host(name, properties)
    end

    def roles_for(names)
      servers.roles_for(names)
    end

    def primary(role)
      servers.fetch_primary(role)
    end

    def backend
      @backend ||= SSHKit
    end

    attr_writer :backend

    def configure_backend
      backend.configure do |sshkit|
        sshkit.format           = fetch(:format)
        sshkit.output_verbosity = fetch(:log_level)
        sshkit.default_env      = fetch(:default_env)
        sshkit.backend          = fetch(:sshkit_backend, SSHKit::Backend::Netssh)
        sshkit.backend.configure do |backend|
          backend.pty                = fetch(:pty)
          backend.connection_timeout = fetch(:connection_timeout)
          backend.ssh_options        = fetch(:ssh_options) if fetch(:ssh_options)
        end
      end
    end

    def timestamp
      @timestamp ||= Time.now.utc
    end

    private

    def servers
      @servers ||= Servers.new
    end

    def config
      @config ||= Hash.new
    end

    def fetch_for(key, default, &block)
      if block_given?
        config.fetch(key, &block)
      else
        config.fetch(key, default)
      end
    end

  end
end
