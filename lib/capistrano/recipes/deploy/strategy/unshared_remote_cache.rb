require 'capistrano/recipes/deploy/strategy/remote_cache'

module Capistrano
  module Deploy
    module Strategy
      class UnsharedRemoteCache < RemoteCache
        def check!
          super.check do |d|
            d.remote.writable(repository_cache)
          end
        end

        private

        def repository_cache
          configuration[:repository_cache]
        end
      end
    end
  end
end
