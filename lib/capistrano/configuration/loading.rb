module Capistrano
  class Configuration
    module Loading
      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_loading, :initialize
        base.send :alias_method, :initialize, :initialize_with_loading
        base.extend ClassMethods
      end

      module ClassMethods
        # Used by third-party task bundles to identify the capistrano
        # configuration that is loading them. Its return value is not reliable
        # in other contexts. If +require_config+ is not false, an exception
        # will be raised if the current configuration is not set.
        def instance(require_config=false)
          config = Thread.current[:capistrano_configuration]
          if require_config && config.nil?
            raise LoadError, "Please require this file from within a Capistrano recipe"
          end
          config
        end

        # Used internally by Capistrano to specify the current configuration
        # before loading a third-party task bundle.
        def instance=(config)
          Thread.current[:capistrano_configuration] = config
        end
      end

      # The load paths used for locating recipe files.
      attr_reader :load_paths

      def initialize_with_loading(*args) #:nodoc:
        initialize_without_loading(*args)
        @load_paths = [".", File.expand_path(File.join(File.dirname(__FILE__), "../recipes"))]
      end
      private :initialize_with_loading

      # Load a configuration file or string into this configuration.
      #
      # Usage:
      #
      #   load("recipe"):
      #     Look for and load the contents of 'recipe.rb' into this
      #     configuration.
      #
      #   load(:file => "recipe"):
      #     same as above
      #
      #   load(:string => "set :scm, :subversion"):
      #     Load the given string as a configuration specification.
      #
      #   load { ... }
      #     Load the block in the context of the configuration.
      def load(*args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}

        if block
          raise ArgumentError, "loading a block requires 0 arguments" unless options.empty? && args.empty?
          load(:proc => block)

        elsif args.any?
          args.each { |arg| load options.merge(:file => arg) }

        elsif options[:file]
          load_from_file(options[:file], options[:name])

        elsif options[:string]
          instance_eval(options[:string], options[:name] || "<eval>")

        elsif options[:proc]
          instance_eval(&options[:proc])

        else
          raise ArgumentError, "don't know how to load #{options.inspect}"
        end
      end

      # Require another file. This is identical to the standard require method,
      # with the exception that it sets the receiver as the "current" configuration
      # so that third-party task bundles can include themselves relative to
      # that configuration.
      def require(*args) #:nodoc:
        original, self.class.instance = self.class.instance, self
        super
      ensure
        # restore the original, so that require's can be nested
        self.class.instance = original
      end

      private

        # Load a recipe from the named file. If +name+ is given, the file will
        # be reported using that name.
        def load_from_file(file, name=nil)
          file = find_file_in_load_path(file) unless file[0] == ?/
          load :string => File.read(file), :name => name || file
        end

        def find_file_in_load_path(file)
          load_paths.each do |path|
            ["", ".rb"].each do |ext|
              name = File.join(path, "#{file}#{ext}")
              return name if File.file?(name)
            end
          end

          raise LoadError, "no such file to load -- #{file}"
        end
    end
  end
end
