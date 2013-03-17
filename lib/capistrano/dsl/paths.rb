require 'pathname'
module Capistrano
  module DSL
    module Paths

      def deploy_to
        fetch(:deploy_to)
      end

      def deploy_path
        Pathname.new(deploy_to)
      end

      def current_path
        deploy_path.join('current')
      end

      def releases_path
        deploy_path.join('releases')
      end

      def release_path
        releases_path.join(release_timestamp)
      end

      def repo_path
        deploy_path.join('repo')
      end

      def shared_path
        deploy_path.join('shared')
      end

      def revision_log
        deploy_path.join('revisions.log')
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
