require "capistrano/doctor/output_helpers"

module Capistrano
  module Doctor
    class ServersDoctor
      include Capistrano::Doctor::OutputHelpers

      def initialize(env=Capistrano::Configuration.env)
        @servers = env.servers.to_a
      end

      def call
        title("Servers (#{servers.size})")
        rwc = RoleWhitespaceChecker.new(servers)

        table(servers) do |server, row|
          sd = ServerDecorator.new(server)

          row << sd.uri_form
          row << sd.roles
          row << sd.properties
          row.yellow if rwc.any_has_whitespace?(server.roles)
        end

        if rwc.whitespace_roles.any?
          warning "\nWhitespace detected in role(s) #{rwc.whitespace_roles_decorated}. " \
            "This might be a result of a mistyped \"%w()\" array literal."
        end
        puts
      end

      private

      attr_reader :servers

      class RoleWhitespaceChecker
        attr_reader :whitespace_roles, :servers

        def initialize(servers)
          @servers = servers
          @whitespace_roles = find_whitespace_roles
        end

        def any_has_whitespace?(roles)
          roles.any? { |role| include_whitespace?(role) }
        end

        def include_whitespace?(role)
          role =~ /\s/
        end

        def whitespace_roles_decorated
          whitespace_roles.map(&:inspect).join(", ")
        end

        private

        def find_whitespace_roles
          servers.map(&:roles).map(&:to_a).flatten.uniq
                 .select { |role| include_whitespace?(role) }
        end
      end

      class ServerDecorator
        def initialize(server)
          @server = server
        end

        def uri_form
          [
            server.user,
            server.user && "@",
            server.hostname,
            server.port && ":",
            server.port
          ].compact.join
        end

        def roles
          server.roles.to_a.inspect
        end

        def properties
          return "" unless server.properties.keys.any?
          pretty_inspect(server.properties.to_h)
        end

        private

        attr_reader :server

        # Hashes with proper padding
        def pretty_inspect(element)
          return element.inspect unless element.is_a?(Hash)

          pairs_string = element.keys.map do |key|
            [pretty_inspect(key), pretty_inspect(element.fetch(key))].join(" => ")
          end.join(", ")

          "{ #{pairs_string} }"
        end
      end
    end
  end
end
