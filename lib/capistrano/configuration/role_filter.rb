require 'capistrano/configuration/regex_filter'

module Capistrano
  class Configuration
    class RoleFilter
      include RegexFilter

      def initialize values
        av = Array(values).dup
        av.map! { |v| v.is_a?(String) ? v.split(',') : v }
        av.flatten!
        @rex = regex_matcher(av)
      end

      def filter servers
        Array(servers).select { |s| s.is_a?(String) ? false : s.roles.any? { |r| @rex.match r } }
      end
    end
  end
end
