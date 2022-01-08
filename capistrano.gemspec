# -*- encoding: utf-8 -*-

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "capistrano/version"

Gem::Specification.new do |gem|
  gem.name          = "capistrano"
  gem.version       = Capistrano::VERSION
  gem.authors       = ["Tom Clements", "Lee Hambley"]
  gem.email         = ["seenmyfate@gmail.com", "lee.hambley@gmail.com"]
  gem.description   = "Capistrano is a utility and framework for executing commands in parallel on multiple remote machines, via SSH."
  gem.summary       = "Capistrano - Welcome to easy deployment with Ruby over SSH"
  gem.homepage      = "https://capistranorb.com/"
  gem.metadata      = {
    "bug_tracker_uri" => "https://github.com/capistrano/capistrano/issues",
    "changelog_uri" => "https://github.com/capistrano/capistrano/releases",
    "source_code_uri" => "https://github.com/capistrano/capistrano",
    "homepage_uri" => "https://capistranorb.com/",
    "documentation_uri" => "https://capistranorb.com/"
  }
  gem.files         = `git ls-files -z`.split("\x0").reject { |f| f =~ /^docs/ }
  gem.executables   = %w(cap capify)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.licenses      = ["MIT"]

  gem.required_ruby_version = ">= 2.0"
  gem.add_dependency "airbrussh", ">= 1.0.0"
  gem.add_dependency "i18n"
  gem.add_dependency "rake", ">= 10.0.0"
  gem.add_dependency "sshkit", ">= 1.9.0"
end
