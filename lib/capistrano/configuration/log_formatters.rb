# Add custom log formatters
#
# Passing a hash or a array of hashes with custom log formatters.
#
# Add the following to your deploy.rb or in your ~/.caprc
#
# == Example:
#
#   capistrano_log_formatters = [
#     { :match => /command finished/,       :color => :hide,      :priority => 10, :prepend => "$$$" },
#     { :match => /executing command/,      :color => :blue,      :priority => 10, :style => :underscore, :timestamp => true },
#     { :match => /^transaction: commit$/,  :color => :magenta,   :priority => 10, :style => :blink },
#     { :match => /git/,                    :color => :white,     :priority => 20, :style => :reverse }
#   ]
#
#   format_logs capistrano_log_formatters
#
# You can call format_logs multiple times, with either a hash or an array of hashes.
#
# == Colors:
#
# :color can have the following values:
#
# * :hide  (hides the row completely)
# * :none
# * :black
# * :red
# * :green
# * :yellow
# * :blue
# * :magenta
# * :cyan
# * :white
#
# == Styles:
#
# :style can have the following values:
#
# * :bright
# * :dim
# * :underscore
# * :blink
# * :reverse
# * :hidden
#
#
#  == Text alterations
#
# :prepend gives static text to be prepended to the output
# :replace replaces the matched text in the output
# :timestamp adds the current time before the output

module Capistrano
  class Configuration
    module LogFormatters
      def log_formatter(options)
        if options.class == Array
          options.each do |option|
            Capistrano::Logger.add_formatter(option)
          end
        else
          Capistrano::Logger.add_formatter(options)
        end
      end

      def default_log_formatters(formatters)
        default_formatters = [*formatters]
      end

      def disable_log_formatters
        @logger.disable_formatters = true
      end
    end
  end
end
