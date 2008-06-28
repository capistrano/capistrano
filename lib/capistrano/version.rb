require 'net/ssh/version'

module Capistrano

  # Describes the current version of Capistrano.
  class Version < Net::SSH::Version
    MAJOR = 2
    MINOR = 4
    TINY  = 3

    # The current version, as a Version instance
    CURRENT = new(MAJOR, MINOR, TINY)

    # The current version, as a String instance
    STRING  = CURRENT.to_s
  end

end
