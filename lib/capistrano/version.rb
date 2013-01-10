module Capistrano
  class Version
    MAJOR = 2
    MINOR = 14
    PATCH = 1

    def self.to_s
      "#{MAJOR}.#{MINOR}.#{PATCH}"
    end
  end
end
