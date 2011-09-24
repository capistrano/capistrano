require 'scanf'
module Capistrano

  class Version

    MAJOR = 2
    MINOR = 9
    PATCH = 0

    def self.to_s
      "#{MAJOR}.#{MINOR}.#{PATCH}"
    end

  end

end
