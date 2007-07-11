require 'net/sftp'
require 'net/sftp/operations/errors'
require 'capistrano/errors'

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

  # This class encapsulates a single file upload to be performed in parallel
  # across multiple machines, using the SFTP protocol. Although it is intended
  # to be used primarily from within Capistrano, it may also be used standalone
  # if you need to simply upload a file to multiple servers.
  #
  # Basic Usage:
  #
  #   begin
  #     uploader = Capistrano::Upload.new(sessions, "remote-file.txt",
  #         :data => "the contents of the file to upload")
  #     uploader.process!
  #   rescue Capistrano::UploadError => e
  #     warn "Could not upload the file: #{e.message}"
  #   end
  class Upload
    def self.process(sessions, filename, options)
      new(sessions, filename, options).process!
    end
  
    attr_reader :sessions, :filename, :options
    attr_reader :failed, :completed

    # Creates and prepares a new Upload instance. The +sessions+ parameter
    # must be an array of open Net::SSH sessions. The +filename+ is the name
    # (including path) of the destination file on the remote server. The
    # +options+ hash accepts the following keys (as symbols):
    #
    # * data: required. Should refer to a String containing the contents of
    #   the file to upload.
    # * mode: optional. The "mode" of the destination file. Defaults to 0660.
    # * logger: optional. Should point to a Capistrano::Logger instance, if
    #   given.
    def initialize(sessions, filename, options)
      raise ArgumentError, "you must specify the data to upload via the :data option" unless options[:data]

      @sessions = sessions
      @filename = filename
      @options  = options

      @completed = @failed = 0
      @sftps = setup_sftp
    end
    
    # Uploads to all specified servers in parallel. If any one of the servers
    # fails, an exception will be raised (UploadError).
    def process!
      logger.debug "uploading #{filename}" if logger
      while running?
        @sftps.each do |sftp|
          next if sftp.channel[:done]
          begin
            sftp.channel.connection.process(true)
          rescue Net::SFTP::Operations::StatusException => error
            logger.important "uploading failed: #{error.description}", sftp.channel[:server] if logger
            failed!(sftp)
          end
        end
        sleep 0.01 # a brief respite, to keep the CPU from going crazy
      end
      logger.trace "upload finished" if logger

      if (failed = @sftps.select { |sftp| sftp.channel[:failed] }).any?
        hosts = failed.map { |sftp| sftp.channel[:server] }
        error = UploadError.new("upload of #{filename} failed on #{hosts.join(',')}")
        error.hosts = hosts
        raise error
      end

      self
    end

    private

      def logger
        options[:logger]
      end

      def setup_sftp
        sessions.map do |session|
          server = session.xserver
          sftp = session.sftp
          sftp.connect unless sftp.state == :open

          sftp.channel[:server] = server
          sftp.channel[:done] = false
          sftp.channel[:failed] = false

          real_filename = filename.gsub(/\$CAPISTRANO:HOST\$/, server.host)
          sftp.open(real_filename, IO::WRONLY | IO::CREAT | IO::TRUNC, options[:mode] || 0660) do |status, handle|
            break unless check_status(sftp, "open #{real_filename}", server, status)
            
            logger.info "uploading data to #{server}:#{real_filename}" if logger
            sftp.write(handle, options[:data] || "") do |status|
              break unless check_status(sftp, "write to #{server}:#{real_filename}", server, status)
              sftp.close_handle(handle) do
                logger.debug "done uploading data to #{server}:#{real_filename}" if logger
                completed!(sftp)
              end
            end
          end
          
          sftp
        end
      end
      
      def check_status(sftp, action, server, status)
        return true if status.code == Net::SFTP::Session::FX_OK

        logger.error "could not #{action} on #{server} (#{status.message})" if logger
        failed!(sftp)

        return false
      end

      def running?
        completed < @sftps.length
      end

      def failed!(sftp)
        completed!(sftp)
        @failed += 1
        sftp.channel[:failed] = true
      end

      def completed!(sftp)
        @completed += 1
        sftp.channel[:done] = true
      end
  end

end
