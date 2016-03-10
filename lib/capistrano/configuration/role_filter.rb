module Capistrano
  class Configuration
    class RoleFilter
      def initialize(values)
        av = Array(values).dup
        av.map! { |v| v.is_a?(String) ? v.split(",") : v }
        av.flatten!
        @rex = regex_matcher(av)
      end

      def filter(servers)
        Array(servers).select { |s| s.is_a?(String) ? false : s.roles.any? { |r| @rex.match r } }
      end

      private

      def regex_matcher(values)
        values.map! do |v|
          case v
          when Regexp then v
          else
            vs = v.to_s
            vs =~ %r{^/(.+)/$} ? Regexp.new($1) : /^#{vs}$/
          end
        end
        Regexp.union values
      end
    end
  end
end
