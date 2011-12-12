require 'scanf'
module Capistrano

  class Version

    MAJOR = 2
    MINOR = 10
    PATCH = 0

    def self.to_s
      "#{MAJOR}.#{MINOR}.#{PATCH}.pre"
    end

  end

end
