module Capistrano
  module DSL
    module Paths
      def deploy_path
        fetch(:deploy_to)
      end

      def current_path
        File.join(deploy_path, 'current')
      end

      def releases_path
        File.join(deploy_path, 'releases')
      end

      def release_path
        File.join(releases_path, release_timestamp)
      end

      def repo_path
        File.join(deploy_path, 'repo')
      end

      def shared_path
        File.join(deploy_path, 'shared')
      end

      def revision_log
        File.join(deploy_path, 'revisions.log')
      end

      def release_timestamp
        env.timestamp.strftime("%Y%m%d%H%M%S")
      end

      def asset_timestamp
        env.timestamp.strftime("%Y%m%d%H%M.%S")
      end
    end
  end
end
