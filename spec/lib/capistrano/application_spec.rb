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

  context '.load_rakefile_once' do
    before :each do
      Capistrano::Application.reset_loaded_rakefiles!
      @my_file = 'my_file.rake'
      @my_load_provider=mock()
    end

    it 'loads a file with full path' do
      @my_load_provider.expects(:load).once.with(File.join(Dir.pwd, @my_file))

      Capistrano::Application.load_rakefile_once(@my_file, @my_load_provider)
    end

    it 'loads a file only once' do

      @my_load_provider.expects(:load).once.with(File.join(Dir.pwd, @my_file))

      Capistrano::Application.load_rakefile_once(@my_file, @my_load_provider)
      Capistrano::Application.load_rakefile_once(@my_file, @my_load_provider)
    end
  end

  it "loads rakefiles only once" do

  end

  it "displays documentation URL as help banner" do
    help_output.lines.first.should match(/capistranorb.com/)
  end

  %w(quiet silent verbose).each do |switch|
    it "doesn't include --#{switch} in help" do
      help_output.should_not match(/--#{switch}/)
    end
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
