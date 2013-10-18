module Capistrano
  module DSL
    module Stages

      def stages_root
        fetch(:stages_root, 'config/deploy')
      end

      # Build stages with nested configurations
      #
      # @example simple stages
      #
      #   config
      #   ├── deploy
      #   │   ├── production.rb
      #   │   └── staging.rb
      #   └── deploy.rb
      #
      # * cap production
      # * cap staging
      #
      # @example stages with nested configurations
      #
      #   config
      #   ├── deploy
      #   │   ├── soa
      #   │   │   ├── blog
      #   │   │   │   ├── production.rb
      #   │   │   │   └── staging.rb
      #   │   │   └── wiki
      #   │   │       └── qa.rb
      #   │   └── soa.rb
      #   └── deploy.rb
      #
      # * cap soa:blog:production
      # * cap soa:blog:staging
      # * cap soa:wiki:qa
      def stages
        Dir["#{stages_root}/**/*.rb"].map { |file|
          file.slice(stages_root.size + 1 .. -4).tr('/', ':')
        }.tap { |paths|
          paths.reject! { |path|
            paths.any? { |another| another != path && another.start_with?(path) }
          }
        }.sort
      end

      def stage_set?
        !!fetch(:stage, false)
      end

    end
  end
end
