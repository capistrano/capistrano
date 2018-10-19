require "spec_helper"

describe Capistrano::Application do
  it "provides a --trace option which enables SSHKit/NetSSH trace output"

  it "provides a --format option which enables the choice of output formatting"

  it "displays documentation URL as help banner", capture_io: true do
    flags "--help", "-h"
    expect($stdout.string.each_line.first).to match(/capistranorb.com/)
  end

  %w(quiet silent verbose).each do |switch|
    it "doesn't include --#{switch} in help", capture_io: true do
      flags "--help", "-h"
      expect($stdout.string).not_to match(/--#{switch}/)
    end
  end

  it "overrides the rake method, but still prints the rake version", capture_io: true do
    flags "--version", "-V"
    out = $stdout.string
    expect(out).to match(/\bCapistrano Version\b/)
    expect(out).to match(/\b#{Capistrano::VERSION}\b/)
    expect(out).to match(/\bRake Version\b/)
    expect(out).to match(/\b#{Rake::VERSION}\b/)
  end

  it "overrides the rake method, and sets the sshkit_backend to SSHKit::Backend::Printer", capture_io: true do
    flags "--dry-run", "-n"
    sshkit_backend = Capistrano::Configuration.fetch(:sshkit_backend)
    expect(sshkit_backend).to eq(SSHKit::Backend::Printer)
  end

  it "enables printing all config variables on command line parameter", capture_io: true do
    begin
      flags "--print-config-variables", "-p"
      expect(Capistrano::Configuration.fetch(:print_config_variables)).to be true
    ensure
      Capistrano::Configuration.reset!
    end
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
    subject.define_singleton_method(:exit) do |*_args|
      throw(:system_exit, :exit)
    end
    subject.run
    subject.options
  end
end
