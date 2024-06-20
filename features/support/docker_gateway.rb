# Ensure Docker container is completely stopped when Ruby exits.
at_exit do
  DockerGateway.new.stop
end

# Manages the Docker-based SSH server that is declared in docker-compose.yml.
class DockerGateway
  def initialize(log_proc=$stderr.method(:puts))
    @log_proc = log_proc
  end

  def start
    run_compose_command("up -d")
  end

  def stop
    run_compose_command("down")
  end

  def run_shell_command(command)
    run_compose_command("exec ssh_server /bin/bash -c #{command.shellescape}")
  end

  private

  def run_compose_command(command)
    log "[docker compose] #{command}"
    stdout, stderr, status = Open3.popen3("docker compose #{command}") do |stdin, stdout, stderr, wait_threads|
      stdin << ""
      stdin.close
      out = Thread.new { read_lines(stdout, &$stdout.method(:puts)) }
      err = Thread.new { stderr.read }
      [out.value, err.value.to_s, wait_threads.value]
    end

    (stdout + stderr).each_line { |line| log "[docker compose] #{line}" }

    [stdout, stderr, status]
  end

  def read_lines(io)
    buffer = + ""
    while (line = io.gets)
      buffer << line
      yield line
    end
    buffer
  end

  def log(message)
    @log_proc.call(message)
  end
end
