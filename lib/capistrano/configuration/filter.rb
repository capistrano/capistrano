require 'capistrano/configuration'

module Capistrano
  class Configuration
    class Filter
      def initialize type, values = nil
        raise "Invalid filter type #{type}" unless [:host,:role].include? type
        av = Array(values)
        @mode = case
                when av.size == 0 then :none
                when av.include?(:all) then :all
                else type
                end
        @rex = case @mode
          when :host
            av.map!{|v| (v.is_a?(String) && v =~ /^(?<name>[-A-Za-z0-9.]+)(,\g<name>)*$/) ? v.split(',') : v }
            av.flatten!
            av.map! do |v|
              case v
              when Regexp then v
              else
                vs = v.to_s
                vs =~ /^[-A-Za-z0-9.]+$/ ? vs : Regexp.new(vs)
              end
            end
            Regexp.union av
          when :role
            av.map!{|v| v.is_a?(String) ? v.split(',') : v }
            av.flatten!
            av.map! do |v|
              case v
              when Regexp then v
              else
                vs = v.to_s
                vs =~ %r{^/(.+)/$} ? Regexp.new($1) : vs
              end
            end
            Regexp.union av
          else
            nil
          end
      end
      def filter servers
        as = Array(servers)
        case @mode
        when :none then return []
        when :all  then return servers
        when :host
          as.select {|s| @rex.match s.hostname}
        when :role
          as.select {|s| s.roles.any? {|r| @rex.match r} }
        end
      end
    end
  end
end
