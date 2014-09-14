require 'capistrano/configuration'

module Capistrano
  class Configuration
    class Filter
      def initialize type, values = nil
        raise "Invalid filter type #{type}" unless [:host,:role].include? type
        av = Array(values)
        @type = type
        @mode = case
                when av.size == 0 then :none
                when av.include?(:all) then :all
                else
                  Regexp.union av.map { |v|
                    case v
                    when Regexp then v
                    else
                      vs = v.to_s
                      vs =~ /^[-\w.]*$/ ? vs : Regexp.new(vs)
                    end
                  }
                end
      end
      def filter servers
        case @mode
        when :none then return []
        when :all  then return servers
        else
          case @type
          when :host
            servers.select {|s| @mode.match s.hostname}
          when :role
            servers.select {|s| s.roles.any? {|r| @mode.match r} }
          end
        end
      end
    end
  end
end
