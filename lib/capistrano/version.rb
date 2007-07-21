module Capistrano
  module Version #:nodoc:
    # A method for comparing versions of required modules. It expects two
    # arrays of integers as parameters, the first being the minimum version
    # required, and the second being the actual version available. It returns
    # true if the actual version is at least equal to the required version.
    def self.check(required, actual) #:nodoc:
      required = required.map { |v| "%06d" % v }.join(".")
      actual   = actual.map { |v| "%06d" % v }.join(".")
      return actual >= required
    end

    MAJOR = 2
    MINOR = 0
    TINY  = 0

    STRING = [MAJOR, MINOR, TINY].join(".")
    
    SSH_REQUIRED = [1,0,10]
    SFTP_REQUIRED = [1,1,0]
  end
end
