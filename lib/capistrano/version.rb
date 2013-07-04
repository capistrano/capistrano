module Capistrano
  class Version
    MAJOR = 2
    MINOR = 15
    PATCH = 5

    def self.to_s
      "#{MAJOR}.#{MINOR}.#{PATCH}"
    end
  end
end
