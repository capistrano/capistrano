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

  # Now, Net::SSH is kind of silly, and tries to lazy-load everything. This
  # wreaks havoc with the parallel connection trick that Capistrano wants to
  # use, so we're going to do something hideously ugly here and force all the
  # files that Net::SSH uses to load RIGHT NOW, rather than lazily.

  net_ssh_dependencies = %w(connection/services connection/channel connection/driver
    service/agentforward/services service/agentforward/driver
    service/process/driver util/prompter
    service/forward/services service/forward/driver service/forward/local-network-handler service/forward/remote-network-handler
    service/shell/services service/shell/driver
    lenient-host-key-verifier
    transport/compress/services transport/compress/zlib-compressor transport/compress/none-compressor transport/compress/zlib-decompressor transport/compress/none-decompressor
    transport/kex/services transport/kex/dh transport/kex/dh-gex
    transport/ossl/services
    transport/ossl/hmac/services transport/ossl/hmac/sha1 transport/ossl/hmac/sha1-96 transport/ossl/hmac/md5 transport/ossl/hmac/md5-96 transport/ossl/hmac/none
    transport/ossl/cipher-factory transport/ossl/hmac-factory transport/ossl/buffer-factory transport/ossl/key-factory transport/ossl/digest-factory
    transport/identity-cipher transport/packet-stream transport/version-negotiator transport/algorithm-negotiator transport/session
    userauth/methods/services userauth/methods/password userauth/methods/keyboard-interactive userauth/methods/publickey userauth/methods/hostbased
    userauth/services userauth/agent userauth/userkeys userauth/driver
    transport/services service/services
  )

  net_ssh_dependencies << "userauth/pageant" if File::ALT_SEPARATOR
  net_ssh_dependencies.each do |path|
    begin
      require "net/ssh/#{path}"
    rescue LoadError
      # Ignore load errors from this, since some files are in the list which
      # do not exist in different (supported) versions of Net::SSH. We know
      # (by this point) that Net::SSH is installed, though, since we do a
      # require 'net/ssh' at the very top of this file, and we know the
      # installed version meets the minimum version requirements because of
      # the version check, also at the top of this file. So, if we get a
      # LoadError, it's simply because the file in question does not exist in
      # the version of Net::SSH that is installed.
      #
      # Whew!
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
    #
    # If an :ssh_options key exists in +options+, it is passed to the Net::SSH
    # constructor. Values in +options+ are then merged into it, and any
    # connection information in +server+ is added last, so that +server+ info
    # takes precedence over +options+, which takes precendence over ssh_options.
    def self.connect(server, options={}, &block)
      methods = [ %w(publickey hostbased), %w(password keyboard-interactive) ]
      password_value = nil
      
      ssh_options = (options[:ssh_options] || {}).dup
      ssh_options[:username] = server.user || options[:user] || ssh_options[:username]
      ssh_options[:port]     = server.port || options[:port] || ssh_options[:port] || DEFAULT_PORT

      begin
        connection_options = ssh_options.merge(
          :password => password_value,
          :auth_methods => ssh_options[:auth_methods] || methods.shift
        )

        connection = Net::SSH.start(server.host, connection_options, &block)
        Server.apply_to(connection, server)

      rescue Net::SSH::AuthenticationFailed
        raise if methods.empty? || ssh_options[:auth_methods]
        password_value = options[:password]
        retry
      end
    end
  end
end
