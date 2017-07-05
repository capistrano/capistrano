require "open3"

module VagrantHelpers
  extend self

  class VagrantSSHCommandError < RuntimeError; end

  at_exit do
    if ENV["KEEP_RUNNING"]
      puts "Vagrant vm will be left up because KEEP_RUNNING is set."
      puts "Rerun without KEEP_RUNNING set to cleanup the vm."
    else
      vagrant_cli_command("destroy -f")
    end
  end

  def vagrant_cli_command(command)
    puts "[vagrant] #{command}"
    stdout, stderr, status = Dir.chdir(VAGRANT_ROOT) do
      Open3.capture3("#{VAGRANT_BIN} #{command}")
    end

    (stdout + stderr).each_line { |line| puts "[vagrant] #{line}" }

    [stdout, stderr, status]
  end

  def run_vagrant_command(command)
    stdout, stderr, status = vagrant_cli_command("ssh -c #{command.inspect}")
    return [stdout, stderr] if status.success?
    raise VagrantSSHCommandError, status
  end
end

World(VagrantHelpers)
