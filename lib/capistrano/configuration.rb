module Capistrano
  class Configuration

    class << self
      def env
        @env ||= new
      end
    end

    def ask(key, default=nil)
      question = Question.new(self, key, default)
      set(key, question)
    end

    def set(key, value)
      config[key] = value
    end

    def fetch(key, default=nil, &block)
      value = fetch_for(key, default, &block)
      if value.respond_to?(:call)
        set(key, value.call)
      else
        value
      end
    end

    def role(name, servers)
      roles.add_role(name, servers)
    end

    def roles_for(names)
      roles.fetch_roles(names)
    end

    def configure_backend
      SSHKit.configure do |sshkit|
        sshkit.format = fetch(:format)
        sshkit.output_verbosity = fetch(:log_level)
        sshkit.backend.configure do |backend|
          backend.pty = fetch(:pty)
        end
      end
    end

    def timestamp
      @timestamp ||= Time.now.utc
    end

    private

    def roles
      @roles ||= Roles.new
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

    class Question

      def initialize(env, key, default)
        @env, @key, @default = env, key, default
      end

      def call
        ask_question
        save_response
      end

      private
      attr_reader :env, :key, :default

      def ask_question
        $stdout.puts question
      end

      def save_response
        env.set(key, value)
      end

      def value
        if response.empty?
          default
        else
          response
        end
      end

      def response
        @response ||= $stdin.gets.chomp
      end

      def question
        I18n.t(:question, key: key, default_value: default, scope: :capistrano)
      end
    end

    class Roles
      include Enumerable

      def add_role(name, servers)
        roles[name] = servers.map { |server| Server.new(server) }
      end

      def fetch_roles(names)
        roles_for(names).flatten.uniq
      end

      def each
        roles.each { |role| yield role }
      end

      private

      def fetch(name)
        roles.fetch(name) { raise "role #{name} is not defined" }
      end

      def roles_for(names)
        if names.include?(:all)
          roles.values
        else
          names.map { |name| fetch name }
        end
      end

      def roles
        @roles ||= Hash.new
      end
    end

    class Server < SSHKit::Host;end;
  end
end
