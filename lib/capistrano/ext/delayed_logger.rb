module Capistrano
  class DelayedLogger
    def initialize(logger)
      @logger = logger
      @buffer = []
    end

    def flush!
      @buffer.each do |name, args, block|
        @logger.send(name, *args, block)
      end
      @buffer = []
    end

    def method_missing(name, *args, &block)
      @buffer << [name, args, block]
    end
  end
end
