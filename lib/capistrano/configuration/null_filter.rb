module Capistrano
  class Configuration
    class NullFilter
      def filter(servers)
        servers
      end
    end
  end
end
