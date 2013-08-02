module Capistrano
  class VersionValidator

    def initialize(version)
      @version = version
    end

    def verify
      if match?
        self
      else
        fail "Capfile locked at #{version}, but #{current_version} is loaded"
      end
    end

    private
    attr_reader :version


    def match?
      available =~ requested
    end

    def current_version
      VERSION
    end

    def available
      Gem::Dependency.new('cap', version)
    end

    def requested
      Gem::Dependency.new('cap', current_version)
    end

  end
end
