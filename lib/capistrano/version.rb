module Capistrano
  class Version
    MAJOR = 2
    MINOR = 13
    PATCH = 4

    def self.to_s
      "#{MAJOR}.#{MINOR}.#{PATCH}"
    end
  end
end
