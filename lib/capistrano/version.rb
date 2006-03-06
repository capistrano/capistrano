module Capistrano
  module Version #:nodoc:
    # A method for comparing versions of required modules. It expects two
    # arrays as parameters, and returns true if the first is no more than the
    # second.
    def self.check(expected, actual) #:nodoc:
      good = false
      if actual[0] > expected[0]
        good = true
      elsif actual[0] == expected[0]
        if actual[1] > expected[1]
          good = true
        elsif actual[1] == expected[1] && actual[2] >= expected[2]
          good = true
        end
      end
    
      good
    end

    MAJOR = 1
    MINOR = 1
    TINY  = 0

    STRING = [MAJOR, MINOR, TINY].join(".")
    
    SSH_REQUIRED = [1,0,8]
    SFTP_REQUIRED = [1,1,0]
  end
end
