module Capistrano
  class Error < RuntimeError; end

  class CaptureError < Error; end
  class ConnectionError < Error; end
  class UploadError < Error; end
  class NoSuchTaskError < Error; end

  class CommandError < Error
    attr_accessor :hosts
  end
end