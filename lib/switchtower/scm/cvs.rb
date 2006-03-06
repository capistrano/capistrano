require 'time'
require 'switchtower/scm/base'

module SwitchTower
  module SCM

    # An SCM module for using CVS as your source control tool. You can
    # specify it by placing the following line in your configuration:
    #
    #   set :scm, :cvs
    #
    # Also, this module accepts a <tt>:cvs</tt> configuration variable,
    # which (if specified) will be used as the full path to the cvs
    # executable on the remote machine:
    #
    #   set :cvs, "/opt/local/bin/cvs"
    #
    # You can specify the location of your local copy (used to query
    # the revisions, etc.) via the <tt>:local</tt> variable, which defaults to
    # ".".
    #
    # You may also specify a <tt>:branch</tt> configuration variable,
    # which (if specified) will be used in the '-r' option to the cvs
    # check out command.  If it is not set, the module will determine if a
    # branch is being used in the CVS sandbox relative to
    # <tt>:local</tt> and act accordingly.   
    #
    #   set :branch, "prod-20060124"
    #
    # Also, you can specify the CVS_RSH variable to use on the remote machine(s)
    # via the <tt>:cvs_rsh</tt> variable. This defaults to the value of the
    # CVS_RSH environment variable locally, or if it is not set, to "ssh".
    class Cvs < Base
      def initialize(configuration)
        super(configuration)
        if not configuration.respond_to?(:branch) then
          configuration.set(:branch) { self.current_branch }
        else
          @current_branch = configuration[:branch]
        end
     end

      # Return a string representing the date of the last revision (CVS is
      # seriously retarded, in that it does not give you a way to query when
      # the last revision was made to the repository, so this is a fairly
      # expensive operation...)
      def latest_revision
        return @latest_revision if @latest_revision
        configuration.logger.debug "querying latest revision..."
        @latest_revision = cvs_log(cvs_local, configuration.branch).
          split(/\r?\n/).
          grep(/^date: (.*?);/) { Time.parse($1).strftime("%Y-%m-%d %H:%M:%S") }.
          sort.
          last
      end

      # Return a string representing the branch that the sandbox
      # relative to <tt>:local</tt> contains.
      def current_branch 
        return @current_branch if @current_branch
        configuration.logger.debug "determining current_branch..."
        @current_branch = cvs_branch(cvs_local)
      end

      # Check out (on all servers associated with the current task) the latest
      # revision, using a branch if necessary. Uses the given actor instance 
      # to execute the command.
      def checkout(actor)
        cvs = configuration[:cvs] || "cvs"
        cvs_rsh = configuration[:cvs_rsh] || ENV['CVS_RSH'] || "ssh"

        if "HEAD" == configuration.branch then
            branch_option = ""
        else
            branch_option = "-r #{configuration.branch}"
        end

        command = <<-CMD
          cd #{configuration.releases_path};
          CVS_RSH="#{cvs_rsh}" #{cvs} -d #{configuration.repository} -Q co -D "#{configuration.revision}" #{branch_option} -d #{File.basename(actor.release_path)} #{actor.application};
        CMD

        run_checkout(actor, command) do |ch, stream, out|
          prefix = "#{stream} :: #{ch[:host]}"
          actor.logger.info out, prefix
          if out =~ %r{password:}
            actor.logger.info "CVS is asking for a password", prefix
            ch.send_data "#{actor.password}\n"
          elsif out =~ %r{^Enter passphrase}
            message = "CVS needs your key's passphrase and cannot proceed"
            actor.logger.info message, prefix
            raise message
          end
        end
      end

      private

        # Look for a 'CVS/Tag' file in the path.  If this file exists
        # and contains a Line starting with 'T' then this CVS sandbox is
        # 'tagged' with a branch.  In the default case return 'HEAD'
        def cvs_branch(path)
          branch = "HEAD"
          branch_file = File.join(path || ".", "CVS", "Tag")
          if File.exists?(branch_file) then
            File.open(branch_file) do |f|
              possible_branch = f.find { |l| l =~ %r{^T} }
              branch = possible_branch.strip[1..-1] if possible_branch
            end
          end
          branch
        end

        def cvs_log(path,branch)
          `cd #{path || "."} && cvs -q log -N -r#{branch}`
        end

        def cvs_local
          configuration.local || "."
        end
    end

  end
end
