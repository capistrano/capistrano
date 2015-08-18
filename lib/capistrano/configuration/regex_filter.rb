module Capistrano
  class Configuration
    module RegexFilter
      def regex_matcher values
        av = values.map do |v|
          case v
          when Regexp then v
          else
            vs = v.to_s
            vs =~ %r{^/(.+)/$} ? Regexp.new($1) : %r{^#{vs}$}
          end
        end
        Regexp.union av
      end
    end
  end
end
