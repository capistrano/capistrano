module Capistrano
  module Version #:nodoc:
    # A method for comparing versions of required modules. It expects
    # arrays as parameters, and returns true if the first is no less than the
    # second, and strictly less than the third.
    def self.check(actual, minimum, maximum) #:nodoc:
      actual = actual[0] * 1_000_000 + actual[1] * 1_000 + actual[2]
      minimum = minimum[0] * 1_000_000 + minimum[1] * 1_000 + minimum[2]
      maximum = maximum[0] * 1_000_000 + maximum[1] * 1_000 + maximum[2]

      return actual >= minimum && actual < maximum
    end

    MAJOR = 1
    MINOR = 4
    TINY  = 2

    STRING = [MAJOR, MINOR, TINY].join(".")
    
    MINIMUM_SSH_REQUIRED  = [1,0,10]
    MAXIMUM_SSH_REQUIRED  = [1,99,0]

    MINIMUM_SFTP_REQUIRED = [1,1,0]
    MAXIMUM_SFTP_REQUIRED = [1,99,0]
  end
end
