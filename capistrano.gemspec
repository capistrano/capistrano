# encoding: utf-8

Gem::Specification.new do |s|
  s.name = %q{capistrano}
  s.version = "2.5.20"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamis Buck", "Lee Hambley"]
  s.date = %q{2011-03-22}
  s.description = %q{Capistrano is a utility and framework for executing commands in parallel on multiple remote machines, via SSH.}
  s.email = ["jamis@jamisbuck.org", "lee.hambley@gmail.com"]
  s.executables = ["capify", "cap"]
  s.extra_rdoc_files = [
    "README.mdown"
  ]
  s.files = [
    "CHANGELOG",
    "Gemfile",
    "README.mdown",
    "Rakefile",
    "VERSION",
  ] + Dir.glob('bin/*') + Dir.glob('lib/**/*.rb')
  s.homepage = %q{http://github.com/capistrano/capistrano}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.3}
  s.summary = %q{Capistrano - Welcome to easy deployment with Ruby over SSH}
  s.test_files = [
    "test/cli/execute_test.rb",
    "test/cli/help_test.rb",
    "test/cli/options_test.rb",
    "test/cli/ui_test.rb",
    "test/cli_test.rb",
    "test/command_test.rb",
    "test/configuration/actions/file_transfer_test.rb",
    "test/configuration/actions/inspect_test.rb",
    "test/configuration/actions/invocation_test.rb",
    "test/configuration/callbacks_test.rb",
    "test/configuration/connections_test.rb",
    "test/configuration/execution_test.rb",
    "test/configuration/loading_test.rb",
    "test/configuration/namespace_dsl_test.rb",
    "test/configuration/roles_test.rb",
    "test/configuration/servers_test.rb",
    "test/configuration/variables_test.rb",
    "test/configuration_test.rb",
    "test/deploy/local_dependency_test.rb",
    "test/deploy/remote_dependency_test.rb",
    "test/deploy/scm/accurev_test.rb",
    "test/deploy/scm/base_test.rb",
    "test/deploy/scm/bzr_test.rb",
    "test/deploy/scm/darcs_test.rb",
    "test/deploy/scm/git_test.rb",
    "test/deploy/scm/mercurial_test.rb",
    "test/deploy/scm/none_test.rb",
    "test/deploy/scm/subversion_test.rb",
    "test/deploy/strategy/copy_test.rb",
    "test/extensions_test.rb",
    "test/fixtures/cli_integration.rb",
    "test/fixtures/config.rb",
    "test/fixtures/custom.rb",
    "test/logger_test.rb",
    "test/role_test.rb",
    "test/server_definition_test.rb",
    "test/shell_test.rb",
    "test/ssh_test.rb",
    "test/task_definition_test.rb",
    "test/transfer_test.rb",
    "test/utils.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3
    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0.14"])
      s.add_runtime_dependency(%q<net-sftp>, [">= 2.0.0"])
      s.add_runtime_dependency(%q<net-scp>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<net-ssh-gateway>, [">= 1.0.0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<net-ssh>, [">= 2.0.14"])
      s.add_dependency(%q<net-sftp>, [">= 2.0.0"])
      s.add_dependency(%q<net-scp>, [">= 1.0.0"])
      s.add_dependency(%q<net-ssh-gateway>, [">= 1.0.0"])
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<net-ssh>, [">= 2.0.14"])
    s.add_dependency(%q<net-sftp>, [">= 2.0.0"])
    s.add_dependency(%q<net-scp>, [">= 1.0.0"])
    s.add_dependency(%q<net-ssh-gateway>, [">= 1.0.0"])
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end

