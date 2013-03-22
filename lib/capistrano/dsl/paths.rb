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
        paths = fetch(:linked_dirs)
        join_paths(parent, paths)
      end

      def linked_files(parent)
        paths = fetch(:linked_files)
        join_paths(parent, paths)
      end

      def linked_file_dirs(parent)
        map_dirnames(linked_files(parent))
      end

      def linked_dir_parents(parent)
        map_dirnames(linked_dirs(parent))
      end

      def join_paths(parent, paths)
        paths.map { |path| parent.join(path) }
      end

      def map_dirnames(paths)
        paths.map { |path| path.dirname }
      end
    end
  end
end
