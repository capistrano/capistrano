require "English"

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
    Dir.chdir(VAGRANT_ROOT) do
      `#{VAGRANT_BIN} #{command} 2>&1`.split("\n").each do |line|
        puts "[vagrant] #{line}"
      end
    end
    $CHILD_STATUS
  end

  def run_vagrant_command(command)
    if (status = vagrant_cli_command("ssh -c #{command.inspect}")).success?
      true
    else
      raise VagrantSSHCommandError, status
    end
  end
end

World(VagrantHelpers)
