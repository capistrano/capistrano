require 'capistrano/scm/base'

module Capistrano
  module SCM

    # An SCM module for using Mercurial as your source control tool.
    # You can use it by placing the following line in your configuration:
    #
    #   set :scm, :mercurial
    #
    # Also, this module accepts a <tt>:mercurial</tt> configuration variable,
    # which (if specified) will be used as the full path to the hg
    # executable on the remote machine:
    #
    #   set :mercurial, "/usr/local/bin/hg"
    class Mercurial < Base
      # Return a string identifying the tip changeset in the mercurial
      # repository. Note that this fetches the tip changeset from the
      # local repository, but capistrano will deploy from your _remote_
      # repository. So just make sure your local repository is synchronized
      # with your remote one.
      def latest_revision
        `#{mercurial} tip --template '{node|short}'`
      end

      # Return the changeset currently deployed.
      def current_revision(actor)
        # NOTE:
        # copied almost verbatim from svn except its not cast into an int
        # this should be the same for almost _every_ scm can we take it out
        # of SCM-specific code?
        latest = actor.releases.last
        grep = %(grep " #{latest}$" #{configuration.deploy_to}/revisions.log)
        result = ""
        actor.run(grep, :once => true) do |ch, str, out|
          result << out if str == :out
          raise "could not determine current changeset" if str == :err
        end

        date, time, user, changeset, dir = result.split
        raise "current changeset not found in revisions.log" unless dir == latest
        changeset
      end

      # Return a string containing the diff between the two changesets. +from+
      # and +to+ may be in any format that mercurial recognizes as a valid 
      # changeset. If +from+ is +nil+, it defaults to the last deployed
      # changeset. If +to+ is +nil+, it defaults to the current working
      # directory.
      def diff(actor, from = current_revision(actor), to = nil)
        cmd = "#{mercurial} diff -r #{from}"
        cmd << " -r #{to}" if to
        `#{cmd}`
      end

      # Check out (on all servers associated with the current task) the latest
      # revision. Uses the given actor instance to execute the command. If
      # mercurial asks for a password this will automatically provide it
      # (assuming the requested password is the same as the password for
      # logging into the remote server.) If ssh repository method is used,
      # authorized keys must be setup.
      def checkout(actor)
        command = "#{mercurial} clone -U #{configuration.repository} " +
                  "#{actor.release_path} && " +
                  "#{mercurial} -R #{actor.release_path} update " +
                   "-C #{configuration.revision} &&"
        run_checkout(actor, command, &hg_stream_handler(actor)) 
      end

      private
      def mercurial
        configuration[:mercurial] || "hg"
      end

      def hg_stream_handler(actor)
        Proc.new do |ch, stream, out|
          prefix = "#{stream} :: #{ch[:host]}"
          actor.logger.info out, prefix
        end
      end
    end
  end
end
