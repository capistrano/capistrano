module Capistrano
  class Configuration

    class << self
      def env
        @env ||= new
      end
    end

    def set(key, value)
      config[key] = value
    end

    def fetch(key, default=nil, &block)
      if block_given?
        config.fetch(key, &block)
      else
        config.fetch(key, default)
      end
    end

    def role(name, servers)
      roles.add_role(name, servers)
    end

    def roles_for(names)
      roles.fetch_roles(names)
    end

    def all_roles
      roles.all
    end

    def configure_backend
      SSHKit.configure do |sshkit|
        sshkit.format = fetch(:format, :pretty)
        sshkit.output_verbosity = fetch(:log_level, :debug)
        sshkit.backend.configure do |backend|
          backend.pty = fetch(:pty, false)
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


    class Roles
      include Enumerable

      def add_role(name, servers)
        roles[name] = servers.map { |server| Server.new(server) }
      end

      def fetch_roles(names)
        names.map { |name| fetch name }.flatten.uniq
      end

      def all
        roles.values.flatten.uniq
      end

      def each
        roles.each { |role| yield role }
      end

      private

      def fetch(name)
        roles.fetch(name) { "role #{name} is not defined" }
      end

      def roles
        @roles ||= Hash.new
      end
    end

    class Server < SSHKit::Host;end;
  end
end
