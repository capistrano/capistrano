module Capistrano
  class Configuration
    class EmptyFilter
      def filter(_servers)
        []
      end
    end
  end
end
