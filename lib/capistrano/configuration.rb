require_relative 'configuration/filter'
require_relative 'configuration/question'
require_relative 'configuration/server'
require_relative 'configuration/servers'

module Capistrano
  class Configuration

    def initialize(config = nil)
      @config ||= config
    end

    def self.env
      @env ||= new
    end

    def self.reset!
      @env = new
    end

    def ask(key, default=nil, options={})
      question = Question.new(key, default, options)
      set(key, question)
    end

    def set(key, value)
      config[key] = value
    end

    def set_if_empty(key, value)
      config[key] = value unless config.has_key? key
    end

    def delete(key)
      config.delete(key)
    end

    def fetch(key, default=nil, &block)
      value = fetch_for(key, default, &block)
      while callable_without_parameters?(value)
        value = set(key, value.call)
      end
      return value
    end

    def keys
      config.keys
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

    def setup_filters
      @filters = cmdline_filters.clone
      @filters << Filter.new(:role, ENV['ROLES']) if ENV['ROLES']
      @filters << Filter.new(:host, ENV['HOSTS']) if ENV['HOSTS']
      fh = fetch_for(:filter,{})
      @filters << Filter.new(:host, fh[:host]) if fh[:host]
      @filters << Filter.new(:role, fh[:role]) if fh[:role]
    end

    def add_cmdline_filter(type, values)
      cmdline_filters << Filter.new(type, values)
    end

    def filter list
      setup_filters if @filters.nil?
      @filters.reduce(list) { |l,f| f.filter l }
    end

    private

    def cmdline_filters
      @cmdline_filters ||= []
    end

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

    def callable_without_parameters?(x)
      x.respond_to?(:call) && ( !x.respond_to?(:arity) || x.arity == 0)
    end
  end
end
