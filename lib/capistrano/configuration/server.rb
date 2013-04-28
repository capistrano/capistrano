require 'set'
module Capistrano
  class Configuration
    class Server < SSHKit::Host

      def roles
        @roles ||= Set.new
      end
    end
  end
end
