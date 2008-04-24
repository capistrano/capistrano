module Capistrano
  class Error < RuntimeError; end

  class CaptureError < Error; end
  class NoSuchTaskError < Error; end
  class NoMatchingServersError < Error; end
  
  class RemoteError < Error
    attr_accessor :hosts
  end

  class ConnectionError < RemoteError; end
  class TransferError < RemoteError; end
  class CommandError < RemoteError; end
end
