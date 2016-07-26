module Capistrano
  class Configuration
    class HostFilter
      def initialize(values)
        av = Array(values).dup
        av.map! { |v| v.is_a?(String) && v =~ /^(?<name>[-A-Za-z0-9.]+)(,\g<name>)*$/ ? v.split(",") : v }
        av.flatten!
        @rex = regex_matcher(av)
      end

      def filter(servers)
        Array(servers).select { |s| @rex.match s.to_s }
      end

      private

      def regex_matcher(values)
        values.map! do |v|
          case v
          when Regexp then v
          else
            vs = v.to_s
            vs =~ /^[-A-Za-z0-9.]+$/ ? vs : Regexp.new(vs)
          end
        end
        Regexp.union values
      end
    end
  end
end
