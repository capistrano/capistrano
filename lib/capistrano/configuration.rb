require_relative 'configuration/filter'
require_relative 'configuration/question'
require_relative 'configuration/server'
require_relative 'configuration/servers'

module Capistrano
  class ValidationError < Exception; end

  class Configuration
    def initialize(config=nil)
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

    def set(key, value=nil, &block)
      invoke_validations(key, value, &block)
      config[key] = block || value

      puts "Config variable set: #{key.inspect} => #{config[key].inspect}" if fetch(:print_config_variables, false)

      config[key]
    end

    def set_if_empty(key, value=nil, &block)
      set(key, value, &block) unless config.key? key
    end

    def append(key, *values)
      set(key, Array(fetch(key)).concat(values))
    end

    def remove(key, *values)
      set(key, Array(fetch(key)) - values)
    end

    def delete(key)
      config.delete(key)
    end

    def fetch(key, default=nil, &block)
      value = fetch_for(key, default, &block)
      value = set(key, value.call) while callable_without_parameters?(value)
      value
    end

    def any?(key)
      value = fetch(key)
      if value && value.respond_to?(:any?)
        value.any?
      else
        !fetch(key).nil?
      end
    end

    def validate(key, &validator)
      vs = (validators[key] || [])
      vs << validator
      validators[key] = vs
    end

    def keys
      config.keys
    end

    def is_question?(key)
      value = fetch_for(key, nil)
      !value.nil? && value.is_a?(Question)
    end

    def role(name, hosts, options={})
      if name == :all
        raise ArgumentError, "#{name} reserved name for role. Please choose another name"
      end

      servers.add_role(name, hosts, options)
    end

    def server(name, properties={})
      servers.add_host(name, properties)
    end

    def roles_for(names)
      servers.roles_for(names)
    end

    def role_properties_for(names, &block)
      servers.role_properties_for(names, &block)
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
        configure_sshkit_output(sshkit)
        sshkit.output_verbosity = fetch(:log_level)
        sshkit.default_env      = fetch(:default_env)
        sshkit.backend          = fetch(:sshkit_backend, SSHKit::Backend::Netssh)
        sshkit.backend.configure do |backend|
          backend.pty                = fetch(:pty)
          backend.connection_timeout = fetch(:connection_timeout)
          backend.ssh_options        = (backend.ssh_options || {}).merge(fetch(:ssh_options, {}))
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
      fh = fetch_for(:filter, {}) || {}
      @filters << Filter.new(:host, fh[:hosts]) if fh[:hosts]
      @filters << Filter.new(:role, fh[:roles]) if fh[:roles]
      @filters << Filter.new(:host, fh[:host]) if fh[:host]
      @filters << Filter.new(:role, fh[:role]) if fh[:role]
    end

    def add_cmdline_filter(type, values)
      cmdline_filters << Filter.new(type, values)
    end

    def filter(list)
      setup_filters if @filters.nil?
      @filters.reduce(list) { |l, f| f.filter l }
    end

    private

    def cmdline_filters
      @cmdline_filters ||= []
    end

    def servers
      @servers ||= Servers.new
    end

    def config
      @config ||= {}
    end

    def validators
      @validators ||= {}
    end

    def fetch_for(key, default, &block)
      if block_given?
        config.fetch(key, &block)
      else
        config.fetch(key, default)
      end
    end

    def callable_without_parameters?(x)
      x.respond_to?(:call) && (!x.respond_to?(:arity) || x.arity == 0)
    end

    def invoke_validations(key, value, &block)
      unless value.nil? || block.nil?
        raise Capistrano::ValidationError, 'Value and block both passed to Configuration#set'
      end

      return unless validators.key? key

      validators[key].each do |validator|
        validator.call(key, block || value)
      end
    end

    def configure_sshkit_output(sshkit)
      format_args = [fetch(:format)]
      format_args.push(fetch(:format_options)) if any?(:format_options)

      sshkit.use_format(*format_args)
    end
  end
end
