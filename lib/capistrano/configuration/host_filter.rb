require 'capistrano/configuration/regex_filter'

module Capistrano
  class Configuration
    class HostFilter
      include RegexFilter

      def initialize values
        av = Array(values).dup
        av.map! { |v| (v.is_a?(String) && v =~ /^(?<name>[-A-Za-z0-9.]+)(,\g<name>)*$/) ? v.split(',') : v }
        av.flatten!
        @rex = regex_matcher(av)
      end

      def filter servers
        Array(servers).select { |s| @rex.match s.to_s }
      end
    end
  end
end
