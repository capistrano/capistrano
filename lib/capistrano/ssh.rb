begin
  require 'rubygems'
  gem 'net-ssh', '< 1.99.0'
rescue LoadError, NameError
end

require 'net/ssh'

module Capistrano
  unless ENV['SKIP_VERSION_CHECK']
    require 'capistrano/version'
    require 'net/ssh/version'
    ssh_version = [Net::SSH::Version::MAJOR, Net::SSH::Version::MINOR, Net::SSH::Version::TINY]
    if !Version.check(ssh_version, Version::MINIMUM_SSH_REQUIRED, Version::MAXIMUM_SSH_REQUIRED)
      raise "You have Net::SSH #{ssh_version.join(".")}, but you need a version between #{Version::MINIMUM_SSH_REQUIRED.join(".")}...#{Version::MAXIMUM_SSH_REQUIRED.join(".")}"
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
      
      user, server_stripped, pport = parse_server(server)       

      begin
        ssh_options = { :username => (user || config.user),
                        :password => password_value,
                        :port => ((pport && pport != port) ? pport : port),
                        :auth_methods => methods.shift }.merge(config.ssh_options)
        
        Net::SSH.start(server_stripped,ssh_options,&block)
      rescue Net::SSH::AuthenticationFailed
        raise if methods.empty?
        password_value = config.password
        retry
      end
    end
    
    # This regex is used for its byproducts, the $1-3 match vars.
    # This regex will always match the ssh hostname and if there 
    # is a username or port they will be matched as well. This 
    # allows us to set the username and ssh port right in the 
    # server string:  "username@123.12.123.12:8088"
    # This remains fully backwards compatible and can still be
    # intermixed with the old way of doing things. usernames
    # and ports will be used from the server string if present
    # but they will fall back to the regular defaults when not
    # present. Returns and array like:
    # ['bob', 'demo.server.com', '8088']
    # will always at least return the server:
    # [nil, 'demo.server.com', nil]
    def self.parse_server(server)
      server =~ /^(?:([^;,:=]+)@|)(.*?)(?::(\d+)|)$/
      [$1, $2, $3]
    end  
  end
end
