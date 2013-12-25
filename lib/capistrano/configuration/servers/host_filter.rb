module Capistrano
  class Configuration
    class Servers
      class HostFilter

        def initialize(available)
          @available = available
        end

        def self.for(available)
          new(available).hosts
        end

        def hosts
          if host_filter.any?
            @available.select { |server| host_filter.include? server.hostname }
          else
            @available
          end
        end

        private

        def filter
          if host_filter.any?
            host_filter
          else
            @available
          end
        end

        def host_filter
          env_filter | configuration_filter
        end

        def configuration_filter
          ConfigurationFilter.new.hosts
        end

        def env_filter
          EnvFilter.new.hosts
        end

        class ConfigurationFilter

          def hosts
            if filter
              Array(filter.fetch(:hosts, []))
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

          def hosts
            if filter
              filter.split(',')
            else
              []
            end
          end

          def filter
            ENV['HOSTS']
          end
        end

      end
    end
  end
end
