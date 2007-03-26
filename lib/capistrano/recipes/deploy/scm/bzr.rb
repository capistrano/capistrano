require 'capistrano/recipes/deploy/scm/base'

module Capistrano
  module Deploy
    module SCM

      # Implements the Capistrano SCM interface for the Bazaar-NG revision
      # control system (http://bazaar-vcs.org/).
      class Bzr < Base
        # Sets the default command name for this SCM. Users may override this
        # by setting the :scm_command variable.
        default_command "bzr"

        # Bazaar-NG doesn't support any pseudo-id's, so we'll use the convention
        # in this adapter that the :head symbol means the most recently
        # committed revision.
        def head
          :head
        end

        # Returns the command that will check out the given revision to the
        # given destination.
        def checkout(revision, destination)
          scm :branch, revswitch(revision), repository, destination
        end

        # The bzr 'update' command does not support updating to a specific
        # revision, so this just does update, followed by revert (unless
        # updating to head).
        def sync(revision, destination)
          commands = [scm(:update, destination)]
          commands << [scm(:revert, revswitch(revision), destination)] if revision != head
          commands.join(" && ")
        end

        # The bzr 'export' command would work fine, except it doesn't let you
        # specify the repository itself, so it only works if there is a working
        # tree handy, locally. Since this needs to work even on a remote host
        # where there is no working tree, we'll just do a checkout, followed
        # by a deletion of the ".bzr" metadata directory.
        def export(revision, destination)
          [checkout(revision, destination) && "rm -rf #{destination}/.bzr"].join(" && ")
        end

        # The bzr "diff" command doesn't accept a repository argument, so it
        # must be run from within a working tree.
        def diff(from, to=nil)
          switch = "-r#{from}"
          switch << "..#{to}" if to

          scm :diff, switch
        end

        # Returns a log of changes between the two revisions (inclusive).
        def log(from, to=nil)
          scm :log, "--short", "-r#{from}..#{to}", repository
        end

        # Attempts to translate the given revision identifier to a "real"
        # revision. If the identifier is :head, the "bzr revno" command will
        # be yielded, and the block must execute the command and return the
        # output. The revision will be extracted from the output and returned.
        # If the 'revision' argument, on the other hand, is not :head, it is
        # simply returned.
        def query_revision(revision)
          if revision == head
            yield(scm(:revno, repository)).chomp
          else
            revision
          end
        end

        private

          def revswitch(revision)
            if revision == :head
              nil
            else
              "-r #{revision}"
            end
          end
      end

    end
  end
end
