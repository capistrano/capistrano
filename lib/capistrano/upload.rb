begin
  require 'rubygems'
#  gem 'net-sftp', ">= 1.99.0"
rescue LoadError, NameError
end

require 'net/sftp'
require 'capistrano/errors'

module Capistrano
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
    # * mode: optional. The "mode" of the destination file. Defaults to 0664.
    # * logger: optional. Should point to a Capistrano::Logger instance, if
    #   given.
    def initialize(sessions, filename, options)
      raise ArgumentError, "you must specify the data to upload via the :data option" unless options[:data]

      @sessions = sessions
      @filename = filename
      @options  = options

      @completed = @failed = 0
      @uploaders = setup_uploaders
    end
    
    # Uploads to all specified servers in parallel. If any one of the servers
    # fails, an exception will be raised (UploadError).
    def process!
      logger.debug "uploading #{filename}" if logger
      while running?
        @uploaders.each do |uploader|
          begin
            uploader.sftp.session.process(0)
          rescue Net::SFTP::StatusException => error
            logger.important "uploading failed: #{error.description}", uploader[:server] if logger
            failed!(uploader)
          end
        end
        sleep 0.01 # a brief respite, to keep the CPU from going crazy
      end
      logger.trace "upload finished" if logger

      if (failed = @uploaders.select { |uploader| uploader[:failed] }).any?
        hosts = failed.map { |uploader| uploader[:server] }
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

      def setup_uploaders
        sessions.map do |session|
          server = session.xserver
          sftp = session.sftp

          real_filename = filename.gsub(/\$CAPISTRANO:HOST\$/, server.host)
          logger.info "uploading data to #{server}:#{real_filename}" if logger

          uploader = sftp.upload(StringIO.new(options[:data] || ""), real_filename, :permissions => options[:mode] || 0664) do |event, actor, *args|
            completed!(actor) if event == :finish
          end

          uploader[:server] = server
          uploader[:done] = false
          uploader[:failed] = false

          uploader
        end
      end
      
      def running?
        completed < @uploaders.length
      end

      def failed!(uploader)
        completed!(uploader)
        @failed += 1
        uploader[:failed] = true
      end

      def completed!(uploader)
        @completed += 1
        uploader[:done] = true
      end
  end

end
