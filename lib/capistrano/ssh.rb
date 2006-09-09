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
    # An abstraction to make it possible to connect to the server via public key
    # without prompting for the password. If the public key authentication fails
    # this will fall back to password authentication.
    #
    # If a block is given, the new session is yielded to it, otherwise the new
    # session is returned.
    def self.connect(server, config, port=22, &block)
      methods = [ %w(publickey hostbased), %w(password keyboard-interactive) ]
      password_value = nil

      begin
        ssh_options = { :username => config.user,
                        :password => password_value,
                        :port => port,
                        :auth_methods => methods.shift }.merge(config.ssh_options)
        Net::SSH.start(server,ssh_options,&block)
      rescue Net::SSH::AuthenticationFailed
        raise if methods.empty?
        password_value = config.password
        retry
      end
    end
  end
end
