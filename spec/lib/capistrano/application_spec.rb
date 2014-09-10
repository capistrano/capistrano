require 'spec_helper'

describe Capistrano::Application do

  it "provides a --trace option which enables SSHKit/NetSSH trace output"

  it "provides a --format option which enables the choice of output formatting"

  let(:help_output) do
    out, _ = capture_io do
      flags '--help', '-h'
    end
    out
  end

  it "displays documentation URL as help banner" do
    expect(help_output.lines.first).to match(/capistranorb.com/)
  end

  %w(quiet silent verbose).each do |switch|
    it "doesn't include --#{switch} in help" do
      expect(help_output).not_to match(/--#{switch}/)
    end
  end

  it "overrides the rake method, but still prints the rake version" do
    out, _ = capture_io do
      flags '--version', '-V'
    end
    expect(out).to match(/\bCapistrano Version\b/)
    expect(out).to match(/\b#{Capistrano::VERSION}\b/)
    expect(out).to match(/\bRake Version\b/)
    expect(out).to match(/\b#{RAKEVERSION}\b/)
  end

  it "overrides the rake method, and sets the sshkit_backend to SSHKit::Backend::Printer" do
    out, _ = capture_io do
      flags '--dry-run', '-n'
    end
    sshkit_backend = Capistrano::Configuration.fetch(:sshkit_backend)
    expect(sshkit_backend).to eq(SSHKit::Backend::Printer)
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
