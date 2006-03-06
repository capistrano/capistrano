require 'capistrano/scm/base'

module Capistrano
  module SCM

    # An SCM module for using perforce as your source control tool. 
    # This module can explicitly selected by placing the following line 
    # in your configuration:
    #
    #   set :scm, :perforce
    #
    # Also, this module accepts a <tt>:p4</tt> configuration variable,
    # which (if specified) will be used as the full path to the p4
    # executable on the remote machine:
    #
    #   set :p4, "/usr/local/bin/p4"
    #
    # This module accepts another <tt>:p4sync_flags</tt> configuration 
    # variable, which (if specified) can add extra options. This setting
    # defaults to the value "-f" which forces resynchronization.
    #
    #   set :p4sync_flags, "-f"        
    #
    # This module accepts another <tt>:p4client_root</tt> configuration 
    # variable to handle mapping adjustments.  Perforce doesn't have the 
    # ability to sync to a specific directory (e.g. the release_path); the
    # location being synced to is defined by the client-spec. As such, we 
    # sync the client-spec (defined by <tt>p4client</tt> and then copy from 
    # the determined root of the client-spec mappings to the release_path.
    # In the unlikely event that your client-spec mappings introduces 
    # directory structure above the rails structure, you can override the
    # may need to specify the directory
    #
    #   set :p4client_root, "/user/rmcmahon/project1/code"            
    #
    # Finally, the module accepts a <tt>p4diff2_options</tt> configuration
    # variable. This can be used to manipulate the output when running a
    # diff between what is deployed, and another revision. This option
    # defaults to "-u". Run 'p4 help diff2' for other options.
    #
    class Perforce < Base

      def latest_revision
        configuration.logger.debug "querying latest revision..." unless @latest_revision
        @latest_revision = `#{local_p4} counter change`.strip
        @latest_revision
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
      # and +to+ may be in any format that p4 recognizes as a valid revision
      # identifiers. If +from+ is +nil+, it defaults to the last deployed
      # revision. If +to+ is +nil+, it defaults to #head.
      def diff(actor, from=nil, to=nil)
        from ||= "@#{current_revision(actor)}"
        to ||= "#head"
        p4client = configuration[:p4client]
        p4diff2_options = configuration[:p4diff2_options]||"-u -db"
        `#{local_p4} diff2 #{p4diff2_options} //#{p4client}/...#{from} //#{p4client}/...#{to}`
      end      
      
      # Syncronizes (on all servers associated with the current task) the head
      # revision of the code. Uses the given actor instance to execute the command. 
      #
      def checkout(actor)
        p4sync_flags = configuration[:p4sync_flags] || "-f"
        p4client_root = configuration[:p4client_root] || "`#{remote_p4} client -o | grep ^Root | cut -f2`"
        command = "#{remote_p4} sync #{p4sync_flags} && cp -rf #{p4client_root} #{actor.release_path};"
        run_checkout(actor, command, &p4_stream_handler(actor)) 
      end

      def update(actor)
        raise "#{self.class} doesn't support update(actor)"
      end

      private

        def local_p4	  
          add_standard_p4_options('p4')
        end

        def remote_p4	  
          p4_cmd = configuration[:p4] || 'p4'
          add_standard_p4_options(p4_cmd)
        end
	
        def add_standard_p4_options(p4_location)
          check_settings
          p4_cmd = p4_location	  
          p4_cmd = "#{p4_cmd} -p #{configuration[:p4port]}" if configuration[:p4port]
          p4_cmd = "#{p4_cmd} -u #{configuration[:p4user]}" if configuration[:p4user]
          p4_cmd = "#{p4_cmd} -P #{configuration[:p4passwd]}" if configuration[:p4passwd]
          p4_cmd = "#{p4_cmd} -c #{configuration[:p4client]}" if configuration[:p4client]
          p4_cmd	
        end

        def check_settings
          check_setting(:p4port, "Add set :p4port, <your perforce server details e.g. my.p4.server:1666> to deploy.rb")
          check_setting(:p4user, "Add set :p4user, <your production build username> to deploy.rb")
          check_setting(:p4passwd, "Add set :p4passwd, <your build user password> to deploy.rb")
          check_setting(:p4client, "Add set :p4client, <your client-spec name> to deploy.rb")
        end
	
        def check_setting(p4setting, message)
          raise "#{p4setting} is not configured. #{message}" unless configuration[p4setting]
        end
	
        def p4_stream_handler(actor)
          Proc.new do |ch, stream, out|
            prefix = "#{stream} :: #{ch[:host]}"
            actor.logger.info out, prefix
            if out =~ /\(P4PASSWD\) invalid or unset\./i
	            raise "p4passwd is incorrect or unset"
            elsif out =~ /Can.t create a new user.*/i
	            raise "p4user is incorrect or unset"
            elsif out =~ /Perforce client error\:/i	      
	            raise "p4port is incorrect or unset"
            elsif out =~ /Client \'[\w\-\_\.]+\' unknown.*/i
	            raise "p4client is incorrect or unset"
            end	    
          end
        end	
    end
  end
end
