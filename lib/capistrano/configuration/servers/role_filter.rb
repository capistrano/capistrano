module Capistrano
  class Configuration
    class Servers
      class RoleFilter

        def initialize(required, available)
          @required, @available = required, available
        end

        def self.for(required, available)
          new(required, available).roles
        end

        def roles
          if required.include?(:all)
            available
          else
            required.select { |name| available.include? name }
          end
        end

        private

        def required
          Array(@required).flat_map(&:to_sym)
        end

        def available
          if role_filter.any?
            role_filter
          else
            @available
          end
        end

        def role_filter
          env_filter | configuration_filter
        end

        def configuration_filter
          ConfigurationFilter.new.roles
        end

        def env_filter
          EnvFilter.new.roles
        end

        class ConfigurationFilter

          def roles
            if filter
              Array(filter.fetch(:roles, [])).map(&:to_sym)
            else
              []
            end
          end

          def config
            Configuration.env
          end

          def filter
            config.fetch(:filter) || config.fetch(:select)
          end
        end


        class EnvFilter

          def roles
            if filter
              filter.split(',').map(&:to_sym)
            else
              []
            end
          end

          def filter
            ENV['ROLES']
          end
        end

      end
    end
  end
end
