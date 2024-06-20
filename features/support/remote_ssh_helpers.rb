require "open3"
require "socket"
require_relative "docker_gateway"

module RemoteSSHHelpers
  extend self

  class RemoteSSHCommandError < RuntimeError; end

  def start_ssh_server
    docker_gateway.start
  end

  def wait_for_ssh_server(retries=3)
    Socket.tcp("localhost", 2022, connect_timeout: 1).close
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
    retries -= 1
    sleep(2) && retry if retries.positive?
    raise
  end

  def run_remote_ssh_command(command)
    stdout, stderr, status = docker_gateway.run_shell_command(command)
    return [stdout, stderr] if status.success?
    raise RemoteSSHCommandError, status
  end

  def docker_gateway
    @docker_gateway ||= DockerGateway.new(method(:log))
  end
end

World(RemoteSSHHelpers)
