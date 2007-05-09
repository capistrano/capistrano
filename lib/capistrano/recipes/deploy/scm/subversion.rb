require 'capistrano/recipes/deploy/scm/base'
require 'yaml'

module Capistrano
  module Deploy
    module SCM

      # Implements the Capistrano SCM interface for the Subversion revision
      # control system (http://subversion.tigris.org).
      class Subversion < Base
        # Sets the default command name for this SCM. Users may override this
        # by setting the :scm_command variable.
        default_command "svn"

        # Subversion understands 'HEAD' to refer to the latest revision in the
        # repository.
        def head
          "HEAD"
        end

        # Returns the command that will check out the given revision to the
        # given destination.
        def checkout(revision, destination)
          scm :checkout, verbose, authentication, "-r#{revision}", repository, destination
        end

        # Returns the command that will do an "svn update" to the given
        # revision, for the working copy at the given destination.
        def sync(revision, destination)
          scm :update, verbose, authentication, "-r#{revision}", destination
        end

        # Returns the command that will do an "svn export" of the given revision
        # to the given destination.
        def export(revision, destination)
          scm :export, verbose, authentication, "-r#{revision}", repository, destination
        end

        # Returns the command that will do an "svn diff" for the two revisions.
        def diff(from, to=nil)
          scm :diff, repository, authentication, "-r#{from}:#{to || head}"
        end

        # Returns an "svn log" command for the two revisions.
        def log(from, to=nil)
          scm :log, repository, authentication, "-r#{from}:#{to || head}"
        end

        # Attempts to translate the given revision identifier to a "real"
        # revision. If the identifier is an integer, it will simply be returned.
        # Otherwise, this will yield a string of the commands it needs to be
        # executed (svn info), and will extract the revision from the response.
        def query_revision(revision)
          return revision if revision =~ /^\d+$/
          result = yield(scm(:info, repository, authentication, "-r#{revision}"))
          YAML.load(result)['Revision']
        end

        # Determines what the response should be for a particular bit of text
        # from the SCM. Password prompts, connection requests, passphrases,
        # etc. are handled here.
        def handle_data(state, stream, text)
	        logger.info "[#{stream}] #{text}"
          case text
          when /\bpassword.*:/i
            # subversion is prompting for a password
            "#{variable(:scm_password) || variable(:password)}\n"
          when %r{\(yes/no\)}
            # subversion is asking whether or not to connect
            "yes\n"
          when /passphrase/i
            # subversion is asking for the passphrase for the user's key
            "#{variable(:scm_passphrase)}\n"
          when /The entry \'(.+?)\' is no longer a directory/
            raise Capisrano::Error, "subversion can't update because directory '#{$1}' was replaced. Please add it to svn:ignore."
          when /accept \(t\)emporarily/
            # subversion is asking whether to accept the certificate
            "t\n"
          end
        end

        private

          # If a username or password is configured for the SCM, return the
          # command-line switches for those values.
          def authentication
            auth = ""
            auth << "--username #{variable(:scm_username)} " if variable(:scm_username)
            auth << "--password #{variable(:scm_password)} " if variable(:scm_password)
            auth << "--no-auth-cache" if !auth.empty?
            auth
          end

          # If verbose output is requested, return nil, otherwise return the
          # command-line switch for "quiet" ("-q").
          def verbose
            variable(:scm_verbose) ? nil : "-q"
          end
      end

    end
  end
end
