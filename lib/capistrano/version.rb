module Capistrano

  class Version

    CURRENT = File.read(File.dirname(__FILE__) + '/../../VERSION')

    STRING = CURRENT.to_s

    def self.to_s
      CURRENT
    end
    
  end

end
