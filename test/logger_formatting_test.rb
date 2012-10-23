require File.expand_path("../utils", __FILE__)
require 'capistrano/logger'
require 'stringio'

Capistrano::Logger.class_eval do
  # Allows formatters to be changed during tests
  def self.formatters=(formatters)
    @formatters = formatters
    @sorted_formatters = nil
  end
end

class LoggerFormattingTest < Test::Unit::TestCase
  def setup
    @io = StringIO.new
    @io.stubs(:tty?).returns(true)
    @logger = Capistrano::Logger.new(:output => @io, :level => 3)
  end

  def test_matching_with_style_and_color
    Capistrano::Logger.formatters = [{ :match => /^err ::/, :color => :red, :style => :underscore, :level => 0 }]
    @logger.log(0, "err :: Error Occurred")
    assert @io.string.include? "\e[4;31merr :: Error Occurred\e[0m"
  end

  def test_style_without_color
    Capistrano::Logger.formatters = [{ :match => /.*/, :style => :underscore, :level => 0 }]
    @logger.log(0, "test message")
    # Default color should be blank (0m)
    assert @io.string.include? "\e[4;0mtest message\e[0m"
  end

  def test_prepending_text
    Capistrano::Logger.formatters = [{ :match => /^executing/, :level => 0, :prepend => '== Currently ' }]
    @logger.log(0, "executing task")
    assert @io.string.include? '== Currently executing task'
  end

  def test_replacing_matched_text
    Capistrano::Logger.formatters = [{ :match => /^executing/, :level => 0, :replace => 'running' }]
    @logger.log(0, "executing task")
    assert @io.string.include? 'running task'
  end

  def test_prepending_timestamps
    Capistrano::Logger.formatters = [{ :match => /.*/, :level => 0, :timestamp => true }]
    @logger.log(0, "test message")
    assert @io.string.match /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} test message/
  end

  def test_formatter_priorities
    Capistrano::Logger.formatters = [
      { :match => /.*/, :color => :red,  :level => 0, :priority => -10 },
      { :match => /.*/, :color => :blue, :level => 0, :priority => -20, :prepend => '###' }
    ]

    @logger.log(0, "test message")
    # Only the red formatter (color 31) should be applied.
    assert @io.string.include? "\e[31mtest message"
    # The blue formatter should not have prepended $$$
    assert !@io.string.include?('###')
  end

  def test_no_formatting_if_no_color_or_style
    Capistrano::Logger.formatters = []
    @logger.log(0, "test message")
    assert @io.string.include? "*** test message"
  end

  def test_formatter_log_levels
    Capistrano::Logger.formatters = [{ :match => /.*/, :color => :blue, :level => 3 }]
    @logger.log(0, "test message")
    # Should not match log level
    assert @io.string.include? "*** test message"

    clear_logger
    @logger.log(3, "test message")
    # Should match log level and apply blue color
    assert @io.string.include? "\e[34mtest message"
  end

  private

  def colorize(message, color, style = nil)
    style = "#{style};" if style
    "\e[#{style}#{color}m" + message + "\e[0m"
  end

  def clear_logger
    @io = StringIO.new
    @io.stubs(:tty?).returns(true)
    @logger.device = @io
  end
end