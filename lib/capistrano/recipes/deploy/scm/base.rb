module Capistrano
  module Deploy
    module SCM

      # The ancestor class for all Capistrano SCM implementations. It provides
      # minimal infrastructure for subclasses to build upon and override.
      #
      # Note that subclasses that implement this abstract class only return
      # the commands that need to be executed--they do not execute the commands
      # themselves. In this way, the deployment method may execute the commands
      # either locally or remotely, as necessary.
      class Base
        class << self
          # If no parameters are given, it returns the current configured
          # name of the command-line utility of this SCM. If a parameter is
          # given, the defeault command is set to that value.
          def default_command(value=nil)
            if value
              @default_command = value
            else
              @default_command
            end
          end
        end

        # The options available for this SCM instance to reference. Should be
        # treated like a hash.
        attr_reader :configuration

        # Creates a new SCM instance with the given configuration options.
        def initialize(configuration={})
          @configuration = configuration
        end

        # Returns the string used to identify the latest revision in the
        # repository. This will be passed as the "revision" parameter of
        # the methods below.
        def head
          raise NotImplementedError, "`head' is not implemented by #{self.class.name}"
        end

        # Checkout a copy of the repository, at the given +revision+, to the
        # given +destination+. The checkout is suitable for doing development
        # work in, e.g. allowing subsequent commits and updates.
        def checkout(revision, destination)
          raise NotImplementedError, "`checkout' is not implemented by #{self.class.name}"
        end

        # Resynchronize the working copy in +destination+ to the specified
        # +revision+.
        def sync(revision, destination)
          raise NotImplementedError, "`sync' is not implemented by #{self.class.name}"
        end

        # Compute the difference between the two revisions, +from+ and +to+.
        def diff(from, to=nil)
          raise NotImplementedError, "`diff' is not implemented by #{self.class.name}"
        end

        # Return a log of all changes between the two specified revisions,
        # +from+ and +to+, inclusive.
        def log(from, to=nil)
          raise NotImplementedError, "`log' is not implemented by #{self.class.name}"
        end

        # If the given revision represents a "real" revision, this should
        # simply return the revision value. If it represends a pseudo-revision
        # (like Subversions "HEAD" identifier), it should yield a string
        # containing the commands that, when executed will return a string
        # that this method can then extract the real revision from.
        def query_revision(revision)
          raise NotImplementedError, "`query_revision' is not implemented by #{self.class.name}"
        end

        # Should analyze the given text and determine whether or not a
        # response is expected, and if so, return the appropriate response.
        # If no response is expected, return nil. The +state+ parameter is a
        # hash that may be used to preserve state between calls. This method
        # is used to define how Capistrano should respond to common prompts
        # and messages from the SCM, like password prompts and such. By
        # default, the output is simply displayed.
        def handle_data(state, stream, text)
          logger.info "[#{stream}] #{text}"
          nil
        end

        # Returns the name of the command-line utility for this SCM. It first
        # looks at the :scm_command variable, and if it does not exist, it
        # then falls back to whatever was defined by +default_command+.
        def command
          configuration[:scm_command] || default_command
        end

        private

          # A reference to a Logger instance that the SCM can use to log
          # activity.
          def logger
            @logger ||= configuration[:logger] || Capistrano::Logger.new(STDOUT)
          end

          # A helper for accessing the default command name for this SCM. It
          # simply delegates to the class' +default_command+ method.
          def default_command
            self.class.default_command
          end

          # A helper method that can be used to define SCM commands naturally.
          # It returns a single string with all arguments joined by spaces,
          # with the scm command prefixed onto it.
          def scm(*args)
            [command, *args].compact.join(" ")
          end

          # A convenience method for accessing the declared repository value.
          def repository
            configuration[:repository]
          end
      end

    end
  end
end
