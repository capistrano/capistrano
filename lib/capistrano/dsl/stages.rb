module Capistrano
  module DSL
    module Stages

      def stages
        Dir['config/deploy/*.rb'].map { |f| File.basename(f, '.rb') }
      end

      def stage_set?
        !!fetch(:stage, false)
      end

    end
  end
end
