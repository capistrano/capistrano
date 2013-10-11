module Capistrano
  module DSL
    module Stages

      def stages
        Dir[stage_definitions].map { |f| File.basename(f, '.rb') }
      end

      def infer_stages_from_stage_files
      end

      def stage_definitions
        stage_config_path.join('*.rb')
      end

      def stage_set?
        !!fetch(:stage, false)
      end

    end
  end
end
