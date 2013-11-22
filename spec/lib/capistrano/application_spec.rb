require 'spec_helper'

describe Capistrano::Application do

  it "provides a --trace option which enables SSHKit/NetSSH trace output"

  it "provides a --format option which enables the choice of output formatting"

  it "identifies itself as cap and not rake" do
    out, _ = capture_io do
      flags '--help', '-h'
    end
    out.lines.first.should match(/cap \[-f rakefile\]/)
  end

  it "overrides the rake method, but still prints the rake version" do
    out, _ = capture_io do
      flags '--version', '-V'
    end
    out.should match(/\bCapistrano Version\b/)
    out.should match(/\b#{Capistrano::VERSION}\b/)
    out.should match(/\bRake Version\b/)
    out.should match(/\b#{RAKEVERSION}\b/)
  end

  def flags(*sets)
    sets.each do |set|
      ARGV.clear
      @exit = catch(:system_exit) { command_line(*set) }
    end
    yield(subject.options) if block_given?
  end

  def command_line(*options)
    options.each { |opt| ARGV << opt }
    def subject.exit(*args)
      throw(:system_exit, :exit)
    end
    subject.run
    subject.options
  end

  def capture_io
    require 'stringio'

    orig_stdout, orig_stderr         = $stdout, $stderr
    captured_stdout, captured_stderr = StringIO.new, StringIO.new
    $stdout, $stderr                 = captured_stdout, captured_stderr

    yield

    return captured_stdout.string, captured_stderr.string
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
  end

end
