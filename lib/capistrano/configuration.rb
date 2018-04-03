require_relative "configuration/filter"
require_relative "configuration/question"
require_relative "configuration/plugin_installer"
require_relative "configuration/server"
require_relative "configuration/servers"
require_relative "configuration/validated_variables"
require_relative "configuration/variables"

module Capistrano
  class ValidationError < RuntimeError; end

  class Configuration
    def self.env
      @env ||= new
    end

    def self.reset!
      @env = new
    end

    extend Forwardable
    attr_reader :variables
    def_delegators :variables,
                   :set, :fetch, :fetch_for, :delete, :keys, :validate

    def initialize(values={})
      @variables = ValidatedVariables.new(Variables.new(values))
    end

    def ask(key, default=nil, options={})
      question = Question.new(key, default, options)
      set(key, question)
    end

    def set_if_empty(key, value=nil, &block)
      set(key, value, &block) unless keys.include?(key)
    end

    def append(key, *values)
      set(key, Array(fetch(key)).concat(values))
    end

    def remove(key, *values)
      set(key, Array(fetch(key)) - values)
    end

    def any?(key)
      value = fetch(key)
      if value && value.respond_to?(:any?)
        begin
          return value.any?
        rescue ArgumentError # rubocop:disable Lint/HandleExceptions
          # Gracefully ignore values whose `any?` method doesn't accept 0 args
        end
      end

      !value.nil?
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

    def configure_scm
      Capistrano::Configuration::SCMResolver.new.resolve
    end

    def timestamp
      @timestamp ||= Time.now.utc
    end

    def add_filter(filter=nil, &block)
      if block
        raise ArgumentError, "Both a block and an object were given" if filter

        filter = Object.new
        def filter.filter(servers)
          block.call(servers)
        end
      elsif !filter.respond_to? :filter
        raise TypeError, "Provided custom filter <#{filter.inspect}> does " \
                         "not have a public 'filter' method"
      end
      @custom_filters ||= []
      @custom_filters << filter
    end

    def setup_filters
      @filters = cmdline_filters
      @filters += @custom_filters if @custom_filters
      @filters << Filter.new(:role, ENV["ROLES"]) if ENV["ROLES"]
      @filters << Filter.new(:host, ENV["HOSTS"]) if ENV["HOSTS"]
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

    def dry_run?
      fetch(:sshkit_backend) == SSHKit::Backend::Printer
    end

    def install_plugin(plugin, load_hooks: true, load_immediately: false)
      installer.install(plugin,
                        load_hooks: load_hooks,
                        load_immediately: load_immediately)
    end

    def scm_plugin_installed?
      installer.scm_installed?
    end

    def servers
      @servers ||= Servers.new
    end

    private

    def cmdline_filters
      @cmdline_filters ||= []
    end

    def installer
      @installer ||= PluginInstaller.new
    end

    def configure_sshkit_output(sshkit)
      format_args = [fetch(:format)]
      format_args.push(fetch(:format_options)) if any?(:format_options)

      sshkit.use_format(*format_args)
    end
  end
end
