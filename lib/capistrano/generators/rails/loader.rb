module Capistrano
  module Generators
    class RailsLoader
      def self.load!(options)
        require "#{options[:apply_to]}/config/environment"
        require "rails_generator"
        require "rails_generator/scripts/generate"

        Rails::Generator::Base.sources << Rails::Generator::PathSource.new(
          :capistrano, File.dirname(__FILE__))

        args = ["deployment"]
        args << (options[:application] || "Application")
        args << (options[:recipe_file] || "deploy")

        Rails::Generator::Scripts::Generate.new.run(args)
      end
    end
  end
end
