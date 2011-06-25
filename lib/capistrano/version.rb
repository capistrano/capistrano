require 'scanf'
module Capistrano

  class Version

    MAJOR = 2
    MINOR = 6
    PATCH = 1

    def self.to_s
      "#{MAJOR}.#{MINOR}.#{PATCH}.pre"
    end

  end

end
