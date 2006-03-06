require 'switchtower/scm/base'

module SwitchTower
  module SCM

    # An SCM module for using Bazaar as your source control tool. This
    # module is used by default, but you can explicitly specify it by
    # placing the following line in your configuration:
    #
    #   set :scm, :baz
    #
    # Also, this module accepts a <tt>:baz</tt> configuration variable,
    # which (if specified) will be used as the full path to the svn
    # executable on the remote machine:
    #
    #   set :baz, "/opt/local/bin/baz"
    #
    # Set the version you wish to deploy as the repository variable, 
    # for example:
    #
    #   set :repository, "you@example.com--dev/yourstuff--trunk--1.0"
    #
    # Ensure that you have already registered the archive on the target
    # machines.
    #
    # As bazaar keeps a great deal of extra information on a checkout,
    # you will probably want to use export instead:
    #
    #   set :checkout, "export"
    #
    # TODO: provide setup recipe to register archive
    class Baz < Base
      # Return an integer identifying the last known revision in the baz
      # repository. (This integer is currently the revision number.)
      def latest_revision
        `#{baz} revisions #{configuration.repository}`.split.last =~ /\-(\d+)$/
        $1
      end

      # Return the number of the revision currently deployed.
      def current_revision(actor)
        latest = actor.releases.last
        grep = %(grep " #{latest}$" #{configuration.deploy_to}/revisions.log)
        result = ""
        actor.run(grep, :once => true) do |ch, str, out|
          result << out if str == :out
          raise "could not determine current revision" if str == :err
        end

        date, time, user, rev, dir = result.split
        raise "current revision not found in revisions.log" unless dir == latest
        rev.to_i
      end

      # Return a string containing the diff between the two revisions. +from+
      # and +to+ may be in any format that bzr recognizes as a valid revision
      # identifier. If +from+ is +nil+, it defaults to the last deployed
      # revision. If +to+ is +nil+, it defaults to the last developed revision.
      def diff(actor, from=nil, to=nil)
        from ||= current_revision(actor)
        to ||= latest_revision
        from = baz_revision_name(from)
        to = baz_revision_name(to)
        `#{baz} delta --diffs -A #{baz_archive} #{baz_version}--#{from} #{baz_version}--#{to}`
      end

      # Check out (on all servers associated with the current task) the latest
      # revision. Uses the given actor instance to execute the command.
      def checkout(actor)
        op = configuration[:checkout] || "get"
        from = baz_revision_name(configuration.revision)
        command = "#{baz} #{op} #{configuration.repository}--#{from} #{actor.release_path} &&"
        run_checkout(actor, command, &baz_stream_handler(actor)) 
      end

      def update(actor)
        command = "cd #{actor.current_path} && #{baz} update &&"
        run_update(actor, command, &baz_stream_handler(actor)) 
      end

      private
        def baz
          configuration[:baz] || "baz"
        end

        def baz_revision_name(number)
          if number.to_i == 0 then
            "base-0"
          else
            "patch-#{number}"
          end
        end

        def baz_archive
          configuration[:repository][/(.*)\//, 1]
        end

        def baz_version
          configuration[:repository][/\/(.*)$/, 1]
        end

        def baz_stream_handler(actor)
          Proc.new do |ch, stream, out|
            prefix = "#{stream} :: #{ch[:host]}"
            actor.logger.info out, prefix
            if out =~ /\bpassword.*:/i
              actor.logger.info "baz is asking for a password", prefix
              ch.send_data "#{actor.password}\n"
            elsif out =~ %r{passphrase}
              message = "baz needs your key's passphrase, sending empty string"
              actor.logger.info message, prefix
              ch.send_data "\n"
            end
          end
        end
    end
  end
end
