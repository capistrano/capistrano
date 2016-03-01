PROJECT_ROOT = File.expand_path("../../../", __FILE__)
VAGRANT_ROOT = File.join(PROJECT_ROOT, "spec/support")
VAGRANT_BIN = ENV["VAGRANT_BIN"] || "vagrant"

at_exit do
  if ENV["KEEP_RUNNING"]
    VagrantHelpers.run_vagrant_command("rm -rf /home/vagrant/var")
  end
end

require_relative "../../spec/support/test_app"
