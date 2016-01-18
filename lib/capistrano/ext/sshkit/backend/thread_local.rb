require "sshkit/backends/abstract"

# Monkey patch older versions of SSHKit to make the currently-executing Backend
# available via a thread local value.
#
# TODO: Remove this code once capistrano.gemspec requires newer SSHKit version.

unless SSHKit::Backend.respond_to?(:current)
  module SSHKit
    module Backend
      def self.current
        Thread.current["sshkit_backend"]
      end

      class Abstract
        def run
          Thread.current["sshkit_backend"] = self
          instance_exec(@host, &@block)
        ensure
          Thread.current["sshkit_backend"] = nil
        end
      end
    end
  end
end
