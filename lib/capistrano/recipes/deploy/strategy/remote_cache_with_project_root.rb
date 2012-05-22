require 'capistrano/recipes/deploy/strategy/remote_cache'

module Capistrano
  module Deploy
    module Strategy

      # Implements the deployment strategy that keeps a cached checkout of
      # the source code on each remote server. Each deploy simply updates the
      # cached checkout, and then does a copy from the cached copy to the
      # final deployment location.
      class RemoteCacheWithProjectRoot < RemoteCache

         def copy_repository_cache
           
            cached_project_root = File.join(repository_cache, project_root) 
            
            logger.trace "copying the cached version from #{cached_project_root} to #{configuration[:release_path]}"

            run "mkdir -p #{configuration[:release_path]}"
            
            if copy_exclude.empty? 
              run "cp -RPp #{cached_project_root}/* #{configuration[:release_path]} && #{mark}"  
            else
              exclusions = copy_exclude.map { |e| "--exclude=\"#{e}\"" }.join(' ')
              run "rsync -lrpt #{exclusions} #{cached_project_root}/* #{configuration[:release_path]} && #{mark}" 
            end
         end 
      end

    end
  end
end
