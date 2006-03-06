require 'capistrano/scm/base'

module Capistrano
  module SCM

    # An SCM module for using Bazaar-NG (bzr) as your source control tool.
    # You can use it by placing the following line in your configuration:
    #
    #   set :scm, :bzr
    #
    # Also, this module accepts a <tt>:bzr</tt> configuration variable,
    # which (if specified) will be used as the full path to the bzr
    # executable on the remote machine:
    #
    #   set :bzr, "/opt/local/bin/bzr"
    class Bzr < Base
      # Return an integer identifying the last known revision in the bzr
      # repository. (This integer is currently the revision number.) 
      def latest_revision
        `#{bzr} revno #{configuration.repository}`.to_i
      end

      # Return the number of the revision currently deployed.
      def current_revision(actor)
        command = "#{bzr} revno #{actor.release_path} &&"        
        run_update(actor, command, &bzr_stream_handler(actor)) 
      end

      # Return a string containing the diff between the two revisions. +from+
      # and +to+ may be in any format that bzr recognizes as a valid revision
      # identifier. If +from+ is +nil+, it defaults to the last deployed
      # revision. If +to+ is +nil+, it defaults to the last developed revision.
      # Pay attention to the fact that as of now bzr does NOT support
      # diff on remote locations.
      def diff(actor, from=nil, to=nil)
        from ||= current_revision(actor)
        to ||= ""
        `#{bzr} diff -r #{from}..#{to} #{configuration.repository}`
      end

      # Check out (on all servers associated with the current task) the latest
      # revision. Uses the given actor instance to execute the command. If
      # bzr asks for a password this will automatically provide it (assuming
      # the requested password is the same as the password for logging into the
      # remote server.)
      def checkout(actor)
        op = configuration[:checkout] || "branch"
        command = "#{bzr} #{op} -r#{configuration.revision} #{configuration.repository} #{actor.release_path} &&"
        run_checkout(actor, command, &bzr_stream_handler(actor)) 
      end

      def update(actor)
        command = "cd #{actor.current_path} && #{bzr} pull -q &&"
        run_update(actor, command, &bzr_stream_handler(actor)) 
      end
      
      private
        def bzr
          configuration[:bzr] || "bzr"
        end

        def bzr_stream_handler(actor)
          Proc.new do |ch, stream, out|
            prefix = "#{stream} :: #{ch[:host]}"
            actor.logger.info out, prefix
          end
        end
    end
  end
end
