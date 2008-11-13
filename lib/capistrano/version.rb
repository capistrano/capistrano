require 'net/ssh/version'

module Capistrano

  # Describes the current version of Capistrano.
  class Version < Net::SSH::Version
    MAJOR = 2
    MINOR = 5
    TINY  = 2

    # The current version, as a Version instance
    CURRENT = new(MAJOR, MINOR, TINY)

    # The current version, as a String instance
    STRING  = CURRENT.to_s
  end

end
