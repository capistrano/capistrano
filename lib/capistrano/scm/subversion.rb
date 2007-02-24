require 'capistrano/scm/base'

module Capistrano
  module SCM

    # An SCM module for using subversion as your source control tool. This
    # module is used by default, but you can explicitly specify it by
    # placing the following line in your configuration:
    #
    #   set :scm, :subversion
    #
    # Also, this module accepts a <tt>:svn</tt> configuration variable,
    # which (if specified) will be used as the full path to the svn
    # executable on the remote machine:
    #
    #   set :svn, "/opt/local/bin/svn"
    class Subversion < Base
      # Return an integer identifying the last known revision in the svn
      # repository. (This integer is currently the revision number.)
      def latest_revision
        @latest_revision ||= begin
            configuration.logger.debug "querying latest revision..."
            match = svn_log(configuration.repository).scan(/r(\d+)/).first or
              raise "Could not determine latest revision"
            match.first
          end
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
      # and +to+ may be in any format that svn recognizes as a valid revision
      # identifier. If +from+ is +nil+, it defaults to the last deployed
      # revision. If +to+ is +nil+, it defaults to HEAD.
      def diff(actor, from=nil, to=nil)
        from ||= current_revision(actor)
        to ||= "HEAD"

        `svn diff #{authorization} #{configuration.repository}@#{from} #{configuration.repository}@#{to}`
      end

      # Check out (on all servers associated with the current task) the latest
      # revision. Uses the given actor instance to execute the command. If
      # svn asks for a password this will automatically provide it (assuming
      # the requested password is the same as the password for logging into the
      # remote server.)
      def checkout(actor)
        op = configuration[:checkout] || "co"
        command = "#{svn} #{op} #{authorization} -q -r#{configuration.revision} #{configuration.repository} #{actor.release_path} &&"
        run_checkout(actor, command, &svn_stream_handler(actor)) 
      end

      # Update the current release in-place. This assumes that the original
      # deployment was made using checkout, and not something like export.
      def update(actor)
        command = "cd #{actor.current_path} && #{svn} up -q &&"
        run_update(actor, command, &svn_stream_handler(actor)) 
      end

      private

        def svn
          configuration[:svn] || "svn"
        end

        def authorization
          username = configuration[:svn_username] ? "--username #{configuration[:svn_username]}" : ""
          password = configuration[:svn_password] ? "--password #{configuration[:svn_password]}" : ""
          "--no-auth-cache #{username} #{password}"
        end

        def svn_log(path)
          `svn log #{authorization} -q --limit 1 #{path}`
        end

        def svn_password
          configuration[:svn_password] || configuration[:password]
        end

        def svn_passphrase
          configuration[:svn_passphrase] || svn_password
        end
        
        def svn_stream_handler(actor)
          Proc.new do |ch, stream, out|
            prefix = "#{stream} :: #{ch[:host]}"
            actor.logger.info out, prefix
            if out =~ /\bpassword.*:/i
              actor.logger.info "subversion is asking for a password", prefix
              ch.send_data "#{svn_password}\n"
            elsif out =~ %r{\(yes/no\)}
              actor.logger.info "subversion is asking whether to connect or not",
                prefix
              ch.send_data "yes\n"
            elsif out =~ %r{passphrase}i
              message = "subversion needs your key's passphrase"
              actor.logger.info message, prefix
              ch.send_data "#{svn_passphrase}\n"
            elsif out =~ %r{The entry \'(\w+)\' is no longer a directory}
              message = "subversion can't update because directory '#{$1}' was replaced. Please add it to svn:ignore."
              actor.logger.info message, prefix
              raise message
            elsif out =~ %r{accept \(t\)emporarily}
              message = "accepting certificate temporarily"
              actor.logger.info message, prefix
              ch.send_data "t\n"
            end
          end
        end
    end

  end
end
