require 'net/ssh'

module Capistrano
  unless ENV['SKIP_VERSION_CHECK']
    require 'capistrano/version'
    require 'net/ssh/version'
    ssh_version = [Net::SSH::Version::MAJOR, Net::SSH::Version::MINOR, Net::SSH::Version::TINY]
    if !Version.check(Version::SSH_REQUIRED, ssh_version)
      raise "You have Net::SSH #{ssh_version.join(".")}, but you need at least #{Version::SSH_REQUIRED.join(".")}"
    end
  end

  # A helper class for dealing with SSH connections.
  class SSH
    # Patch an accessor onto an SSH connection so that we can record the server
    # definition object that defines the connection. This is useful because
    # the gateway returns connections whose "host" is 127.0.0.1, instead of
    # the host on the other side of the tunnel.
    module Server #:nodoc:
      def self.apply_to(connection, server)
        connection.extend(Server)
        connection.xserver = server
        connection
      end

      attr_accessor :xserver
    end

    # The default port for SSH.
    DEFAULT_PORT = 22

    # An abstraction to make it possible to connect to the server via public key
    # without prompting for the password. If the public key authentication fails
    # this will fall back to password authentication.
    #
    # +server+ must be an instance of ServerDefinition.
    #
    # If a block is given, the new session is yielded to it, otherwise the new
    # session is returned.
    def self.connect(server, options={}, &block)
      methods = [ %w(publickey hostbased), %w(password keyboard-interactive) ]
      password_value = nil
      
      begin
        ssh_options = { :username => (server.user || options[:user]),
                        :password => password_value,
                        :port => (server.port || options[:port] || DEFAULT_PORT),
                        :auth_methods => methods.shift }
        ssh_options.update(options[:ssh_options]) if options[:ssh_options]
        
        connection = Net::SSH.start(server.host, ssh_options, &block)
        Server.apply_to(connection, server)

      rescue Net::SSH::AuthenticationFailed
        raise if methods.empty?
        password_value = options[:password]
        retry
      end
    end
  end
end
