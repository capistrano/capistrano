module Capistrano
  class Logger #:nodoc:
    attr_accessor :level, :device, :disable_formatters

    IMPORTANT = 0
    INFO      = 1
    DEBUG     = 2
    TRACE     = 3

    MAX_LEVEL = 3

    COLORS = {
      :none     => "0",
      :black    => "30",
      :red      => "31",
      :green    => "32",
      :yellow   => "33",
      :blue     => "34",
      :magenta  => "35",
      :cyan     => "36",
      :white    => "37"
    }

    STYLES = {
      :bright     => 1,
      :dim        => 2,
      :underscore => 4,
      :blink      => 5,
      :reverse    => 7,
      :hidden     => 8
    }

    # Set up default formatters
    @default_formatters = [
      # TRACE
      { :match => /command finished/,          :color => :white,   :style => :dim, :level => 3, :priority => -10 },
      { :match => /executing locally/,         :color => :yellow,  :level => 3, :priority => -20 },

      # DEBUG
      { :match => /executing `.*/,             :color => :green,   :level => 2, :priority => -10, :timestamp => true },
      { :match => /.*/,                        :color => :yellow,  :level => 2, :priority => -30 },

      # INFO
      { :match => /.*out\] (fatal:|ERROR:).*/, :color => :red,     :level => 1, :priority => -10 },
      { :match => /Permission denied/,         :color => :red,     :level => 1, :priority => -20 },
      { :match => /sh: .+: command not found/, :color => :magenta, :level => 1, :priority => -30 },

      # IMPORTANT
      { :match => /^err ::/,                   :color => :red,     :level => 0, :priority => -10 },
      { :match => /.*/,                        :color => :blue,    :level => 0, :priority => -20 }
    ]
    @formatters = @default_formatters

    class << self
      def default_formatters
        @default_formatters
      end

      def default_formatters=(defaults=nil)
        @default_formatters = [defaults].flatten

        # reset the formatters
        @formatters = @default_formatters
        @sorted_formatters = nil
      end

      def add_formatter(options) #:nodoc:
        @formatters.push(options)
        @sorted_formatters = nil
      end

      def sorted_formatters
        # Sort matchers in reverse order so we can break if we found a match.
        @sorted_formatters ||= @formatters.sort_by { |i| -(i[:priority] || i[:prio] || 0) }
      end
    end

    def initialize(options={})
      output = options[:output] || $stderr
      if output.respond_to?(:puts)
        @device = output
      else
        @device = File.open(output.to_str, "a")
        @needs_close = true
      end

      @options = options
      @level = options[:level] || 0
      @disable_formatters = options[:disable_formatters]
    end

    def close
      device.close if @needs_close
    end

    def log(level, message, line_prefix=nil)
      if level <= self.level
        # Only format output if device is a TTY or formatters are not disabled
        if device.tty? && !@disable_formatters
          color = :none
          style = nil

          Logger.sorted_formatters.each do |formatter|
            if (formatter[:level] == level || formatter[:level].nil?)
              if message =~ formatter[:match] || line_prefix =~ formatter[:match]
                color = formatter[:color] if formatter[:color]
                style = formatter[:style] || formatter[:attribute] # (support original cap colors)
                message.gsub!(formatter[:match], formatter[:replace]) if formatter[:replace]
                message = formatter[:prepend] + message unless formatter[:prepend].nil?
                message = message + formatter[:append] unless formatter[:append].nil?
                message = Time.now.strftime('%Y-%m-%d %T') + ' ' + message if formatter[:timestamp]
                break unless formatter[:replace]
              end
            end
          end

          if color == :hide
            # Don't do anything if color is set to :hide
            return false
          end

          term_color = COLORS[color]
          term_style = STYLES[style]

          # Don't format message if no color or style
          unless color == :none and style.nil?
            unless line_prefix.nil?
              line_prefix = format(line_prefix, term_color, term_style, nil)
            end
            message = format(message, term_color, term_style)
          end
        end

        indent = "%*s" % [MAX_LEVEL, "*" * (MAX_LEVEL - level)]
        (RUBY_VERSION >= "1.9" ? message.lines : message).each do |line|
          if line_prefix
            device.puts "#{indent} [#{line_prefix}] #{line.strip}\n"
          else
            device.puts "#{indent} #{line.strip}\n"
          end
        end
      end
    end

    def important(message, line_prefix=nil)
      log(IMPORTANT, message, line_prefix)
    end

    def info(message, line_prefix=nil)
      log(INFO, message, line_prefix)
    end

    def debug(message, line_prefix=nil)
      log(DEBUG, message, line_prefix)
    end

    def trace(message, line_prefix=nil)
      log(TRACE, message, line_prefix)
    end

    def format(message, color, style, nl = "\n")
      style = "#{style};" if style
      "\e[#{style}#{color}m" + message.to_s.strip + "\e[0m#{nl}"
    end
  end
end
