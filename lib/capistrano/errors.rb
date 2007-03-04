module Capistrano
  class Error < RuntimeError; end

  class CaptureError < Error; end
  class CommandError < Error; end
  class ConnectionError < Error; end
  class UploadError < Error; end
  class NoSuchTaskError < Error; end
end