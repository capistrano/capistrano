module Capistrano
  module DSL
    module Stages
      RESERVED_NAMES = %w(deploy doctor install).freeze
      private_constant :RESERVED_NAMES

      def stages
        names = Dir[stage_definitions].map { |f| File.basename(f, ".rb") }
        assert_valid_stage_names(names)
        names
      end

      def stage_definitions
        stage_config_path.join("*.rb")
      end

      def stage_set?
        !!fetch(:stage, false)
      end

      private

      def assert_valid_stage_names(names)
        invalid = names.find { |n| RESERVED_NAMES.include?(n) }
        return if invalid.nil?

        raise t("error.invalid_stage_name", name: invalid, path: stage_config_path.join("#{invalid}.rb"))
      end
    end
  end
end
