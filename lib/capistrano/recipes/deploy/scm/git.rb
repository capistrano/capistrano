require 'capistrano/recipes/deploy/scm/base'

module Capistrano
  module Deploy
    module SCM

      # An SCM module for using Git as your source control tool with Capistrano
      # 2.0.  If you are using Capistrano 1.x, use this plugin instead:
      #
      #   http://scie.nti.st/2007/3/16/capistrano-with-git-shared-repository
      #
      # Assumes you are using a shared Git repository.
      #
      # Parts of this plugin borrowed from Scott Chacon's version, which I
      # found on the Capistrano mailing list but failed to be able to get
      # working.
      #
      # FEATURES:
      #
      #   * Very simple, only requiring 2 lines in your deploy.rb.
      #   * Can deploy different branches, tags, or any SHA1 easily.
      #   * Supports prompting for password / passphrase upon checkout.
      #     (I am amazed at how some plugins don't do this)
      #   * Supports :scm_command, :scm_password, :scm_passphrase Capistrano
      #     directives.
      #
      # REQUIREMENTS
      # ------------
      #
      # Git is required to be installed on your remote machine(s), because a
      # clone and checkout is done to get the code up there.  This is the way
      # I prefer to deploy; there is no alternative to this, so :deploy_via
      # is ignored.
      #
      # CONFIGURATION
      # -------------
      #
      # Use this plugin by adding the following line in your config/deploy.rb:
      #
      #   set :scm, :git
      #
      # Set <tt>:repository</tt> to the path of your Git repo:
      #
      #   set :repository, "someuser@somehost:/home/myproject"
      #
      # The above two options are required to be set, the ones below are
      # optional.
      #
      # You may set <tt>:branch</tt>, which is the reference to the branch, tag,
      # or any SHA1 you are deploying, for example:
      #
      #   set :branch, "origin/master"
      #
      # Otherwise, HEAD is assumed.  I strongly suggest you set this.  HEAD is
      # not always the best assumption.
      #
      # The <tt>:scm_command</tt> configuration variable, if specified, will
      # be used as the full path to the git executable on the *remote* machine:
      #
      #   set :scm_command, "/opt/local/bin/git"
      #
      # For compatibility with deploy scripts that may have used the 1.x
      # version of this plugin before upgrading, <tt>:git</tt> is still
      # recognized as an alias for :scm_command.
      #
      # Set <tt>:scm_password</tt> to the password needed to clone your repo
      # if you don't have password-less (public key) entry:
      #
      #   set :scm_password, "my_secret'
      #
      # Otherwise, you will be prompted for a password.
      #
      # <tt>:scm_passphrase</tt> is also supported.
      #
      # The remote cache strategy is also supported.
      #
      #   set :repository_cache, "git_master"
      #   set :deploy_via, :remote_cache
      #
      # For faster clone, you can also use shallow cloning.  This will set the
      # '--depth' flag using the depth specified.  This *cannot* be used 
      # together with the :remote_cache strategy
      #
      #   set :git_shallow_clone, 1
      #
      # AUTHORS
      # -------
      #
      # Garry Dolley http://scie.nti.st
      # Contributions by Geoffrey Grosenbach http://topfunky.com
      #              and Scott Chacon http://jointheconversation.org
      
      class Git < Base
        # Sets the default command name for this SCM on your *local* machine.
        # Users may override this by setting the :scm_command variable.
        default_command "git"

        # When referencing "head", use the branch we want to deploy or, by
        # default, Git's reference of HEAD (the latest changeset in the default
        # branch, usually called "master").
        def head
          configuration[:branch] || 'HEAD'
        end

        # Performs a clone on the remote machine, then checkout on the branch
        # you want to deploy.
        def checkout(revision, destination)
          git      = command

          branch   = head

          fail "No branch specified, use for example 'set :branch, \"origin/master\"' in your deploy.rb" unless branch

          if depth = configuration[:git_shallow_clone]
            execute  = "#{git} clone --depth #{depth} #{configuration[:repository]} #{destination} && "
          else
            execute  = "#{git} clone #{configuration[:repository]} #{destination} && "
          end

          execute += "cd #{destination} && #{git} checkout -b deploy #{branch}" 

          execute
        end

        # Merges the changes to 'head' since the last fetch, for remote_cache
        # deployment strategy
        def sync(revision, destination)
          execute = "cd #{destination} && git fetch origin && "

          if head == 'HEAD'
            execute += "git merge origin/HEAD"
          else
            execute += "git merge #{head}"
          end

          execute
        end

        # Returns a string of diffs between two revisions
        def diff(from, to=nil)
          from << "..#{to}" if to
          scm :diff, from
        end

        # Returns a log of changes between the two revisions (inclusive).
        def log(from, to=nil)
          from << "..#{to}" if to
          scm :log, from
        end

        # Getting the actual commit id, in case we were passed a tag
        # or partial sha or something - it will return the sha if you pass a sha, too
        def query_revision(revision)
          yield(scm('rev-parse', revision)).chomp
        end

        def command
          # For backwards compatibility with 1.x version of this module
          configuration[:git] || super
        end

        # Determines what the response should be for a particular bit of text
        # from the SCM. Password prompts, connection requests, passphrases,
        # etc. are handled here.
        def handle_data(state, stream, text)
          logger.info "[#{stream}] #{text}"
          case text
          when /\bpassword.*:/i
            # git is prompting for a password
            unless pass = configuration[:scm_password]
              pass = Capistrano::CLI.password_prompt
            end
            "#{pass}\n"
          when %r{\(yes/no\)}
            # git is asking whether or not to connect
            "yes\n"
          when /passphrase/i
            # git is asking for the passphrase for the user's key
            unless pass = configuration[:scm_passphrase]
              pass = Capistrano::CLI.password_prompt
            end
            "#{pass}\n"
          when /accept \(t\)emporarily/
            # git is asking whether to accept the certificate
            "t\n"
          end
        end
      end
    end
  end
end
