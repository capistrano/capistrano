module Capistrano
  module DSL
    module Logger
      def info(message)
        puts message
      end

      def error(message)
        puts message
      end
    end
  end
end
