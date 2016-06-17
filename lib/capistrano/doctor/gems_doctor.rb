require "capistrano/doctor/output_helpers"

module Capistrano
  module Doctor
    # Prints table of all Capistrano-related gems and their version numbers. If
    # there is a newer version of a gem available, call attention to it.
    class GemsDoctor
      include Capistrano::Doctor::OutputHelpers

      def call
        title("Gems")
        table(all_gem_names) do |gem, row|
          row.yellow if update_available?(gem)
          row << gem
          row << installed_gem_version(gem)
          row << "(update available)" if update_available?(gem)
        end
      end

      private

      def installed_gem_version(gem_name)
        Gem.loaded_specs[gem_name].version
      end

      def update_available?(gem_name)
        latest = Gem.latest_version_for(gem_name)
        return false if latest.nil?
        latest > installed_gem_version(gem_name)
      end

      def all_gem_names
        core_gem_names + plugin_gem_names
      end

      def core_gem_names
        %w(capistrano airbrussh rake sshkit net-ssh) & Gem.loaded_specs.keys
      end

      def plugin_gem_names
        (Gem.loaded_specs.keys - ["capistrano"]).grep(/capistrano/).sort
      end
    end
  end
end
