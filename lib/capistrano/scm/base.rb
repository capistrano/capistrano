module Capistrano
  module SCM

    # The ancestor class of the various SCM module implementations.
    class Base
      attr_reader :configuration

      def initialize(configuration) #:nodoc:
        @configuration = configuration
      end

      def latest_revision
        nil
      end

      def current_revision(actor)
        raise "#{self.class} doesn't support querying the deployed revision"
      end

      def diff(actor, from=nil, to=nil)
        raise "#{self.class} doesn't support diff(from, to)"
      end

      def update(actor)
        raise "#{self.class} doesn't support update(actor)"
      end

      private

        def run_checkout(actor, guts, &block)
          log = "#{configuration.deploy_to}/revisions.log"
          directory = File.basename(configuration.release_path)

          command = <<-STR
            if [[ ! -d #{configuration.release_path} ]]; then
              #{guts}
              #{logging_commands(directory)}
            fi
          STR

          actor.run(command, &block)
        end
        
        def run_update(actor, guts, &block)
          command = <<-STR
            #{guts}
            #{logging_commands}
          STR

          actor.run(command, &block)
        end

        def logging_commands(directory = nil)
          log = "#{configuration.deploy_to}/revisions.log"

          "(test -e #{log} || touch #{log} && chmod 666 #{log}) && " +
          "echo `date +\"%Y-%m-%d %H:%M:%S\"` $USER #{configuration.revision} #{directory} >> #{log};"
        end
    end

  end
end
