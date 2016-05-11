require "pathname"
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
        deploy_path.join(fetch(:current_directory, "current"))
      end

      def releases_path
        deploy_path.join("releases")
      end

      def release_path
        fetch(:release_path, current_path)
      end

      def set_release_path(timestamp=now)
        set(:release_timestamp, timestamp)
        set(:release_path, releases_path.join(timestamp))
      end

      def stage_config_path
        Pathname.new fetch(:stage_config_path, "config/deploy")
      end

      def deploy_config_path
        Pathname.new fetch(:deploy_config_path, "config/deploy.rb")
      end

      def repo_url
        require "cgi"
        require "uri"
        if fetch(:git_http_username) && fetch(:git_http_password)
          URI.parse(fetch(:repo_url)).tap do |repo_uri|
            repo_uri.user     = fetch(:git_http_username)
            repo_uri.password = CGI.escape(fetch(:git_http_password))
          end.to_s
        elsif fetch(:git_http_username)
          URI.parse(fetch(:repo_url)).tap do |repo_uri|
            repo_uri.user = fetch(:git_http_username)
          end.to_s
        else
          fetch(:repo_url)
        end
      end

      def repo_path
        Pathname.new(fetch(:repo_path, ->() { deploy_path.join("repo") }))
      end

      def shared_path
        deploy_path.join("shared")
      end

      def revision_log
        deploy_path.join("revisions.log")
      end

      def now
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
        paths.map(&:dirname).uniq
      end
    end
  end
end
