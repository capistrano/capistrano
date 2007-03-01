require 'net/sftp'

module Capistrano
  unless ENV['SKIP_VERSION_CHECK']
    require 'capistrano/version' 
    require 'net/sftp/version'
    sftp_version = [Net::SFTP::Version::MAJOR, Net::SFTP::Version::MINOR, Net::SFTP::Version::TINY]
    required_version = [1,1,0]
    if !Capistrano::Version.check(required_version, sftp_version)
      raise "You have Net::SFTP #{sftp_version.join(".")}, but you need at least #{required_version.join(".")}. Net::SFTP will not be used."
    end
  end

  # This class encapsulates a single file transfer to be performed in parallel
  # across multiple machines, using the SFTP protocol.
  class Transfer
    def initialize(servers, actor, filename, params={}) #:nodoc:
      @servers = servers
      @actor = actor
      @filename = filename
      @params = params
      @completed = 0
      @failed = 0
      @sftps = setup_transfer
    end
    
    def logger #:nodoc:
      @actor.logger
    end

    # Uploads to all specified servers in parallel.
    def process!
      logger.debug "uploading #{@filename}"

      loop do
        @sftps.each { |sftp| sftp.channel.connection.process(true) }
        break if @completed == @servers.length
      end

      logger.trace "upload finished"

      if @failed > 0
        raise "upload of #{@filename} failed on one or more hosts"
      end

      self
    end

    private

      def setup_transfer
        @servers.map do |server|
          sftp = @actor.sessions[server].sftp
          sftp.connect unless sftp.state == :open

          sftp.open(@filename, IO::WRONLY | IO::CREAT | IO::TRUNC, @params[:mode] || 0660) do |status, handle|
            break unless check_status("open #{@filename}", server, status)
            
            logger.info "uploading data to #{server}:#{@filename}"
            sftp.write(handle, @params[:data] || "") do |status|
              break unless check_status("write to #{server}:#{@filename}", server, status)
              sftp.close_handle(handle) do
                logger.debug "done uploading data to #{server}:#{@filename}"
                @completed += 1
              end
            end
          end
          
          sftp
        end
      end
      
      def check_status(action, server, status)
        if status.code != Net::SFTP::Session::FX_OK
          logger.error "could not #{action} on #{server} (#{status.message})"
          @failed += 1
          @completed += 1
          return false
        end
        
        true
      end
  end

end
