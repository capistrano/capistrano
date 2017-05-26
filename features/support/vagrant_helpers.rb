require "open3"

module VagrantHelpers
  extend self

  attr_accessor :status, :stdout, :stderr

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
    Dir.chdir(VAGRANT_ROOT) do
      @stdout, @stderr, @status = Open3.capture3("#{VAGRANT_BIN} #{command}")
    end

    (@stdout + @stderr).split("\n").each { |line| puts "[vagrant] #{line}" }

    @status
  end

  def run_vagrant_command(command)
    vagrant_cli_command("ssh -c #{command.inspect}")
    return true if @status.success?
    raise VagrantSSHCommandError, @status
  end
end

World(VagrantHelpers)
