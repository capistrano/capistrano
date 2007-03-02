require 'capistrano/upload'

module Capistrano
  class Configuration
    module Actions
      module FileTransfer

        # Store the given data at the given location on all servers targetted
        # by the current task. If <tt>:mode</tt> is specified it is used to
        # set the mode on the file.
        def put(data, path, options={})
          execute_on_servers(options) do |servers|
            targets = servers.map { |s| sessions[s.host] }
            Upload.process(targets, path, :data => data, :mode => options[:mode], :logger => logger)
          end
        end
    
        # Get file remote_path from FIRST server targetted by
        # the current task and transfer it to local machine as path. It will use
        # SFTP if Net::SFTP is installed; otherwise it will fall back to using
        # 'cat', which may cause corruption in binary files.
        #
        # get "#{deploy_to}/current/log/production.log", "log/production.log.web"
        def get(remote_path, path, options = {})
          execute_on_servers(options.merge(:once => true)) do |servers|
            logger.info "downloading `#{servers.first.host}:#{remote_path}' to `#{path}'"
            sftp = sessions[servers.first.host].sftp
            sftp.connect unless sftp.state == :open
            sftp.get_file remote_path, path
            logger.debug "download finished" 
          end
        end

      end
    end
  end
end
