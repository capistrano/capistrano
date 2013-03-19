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

      def linked_dirs(parent)
        fetch(:linked_dirs, []).map { |dir| parent.join(dir) }
      end

      def linked_files(parent)
        fetch(:linked_files, []).map { |file| parent.join(file) }
      end

      def linked_file_dirs(parent)
        linked_files(parent).map { |file| file.dirname }
      end

      def linked_dir_parents(parent)
        linked_dirs(parent).map { |dir| dir.dirname }
      end
    end
  end
end
