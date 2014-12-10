# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano"
  gem.version       = Capistrano::VERSION
  gem.authors       = ["Tom Clements", "Lee Hambley"]
  gem.email         = ["seenmyfate@gmail.com", "lee.hambley@gmail.com"]
  gem.description   = %q{Capistrano is a utility and framework for executing commands in parallel on multiple remote machines, via SSH.}
  gem.summary       = %q{Capistrano - Welcome to easy deployment with Ruby over SSH}
  gem.homepage      = "http://capistranorb.com/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = ['cap', 'capify']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.licenses      = ['MIT']

  gem.post_install_message = <<eos
Capistrano 3.1 has some breaking changes. Please check the CHANGELOG: http://goo.gl/SxB0lr

If you're upgrading Capistrano from 2.x, we recommend to read the upgrade guide: http://goo.gl/4536kB

The `deploy:restart` hook for passenger applications is now in a separate gem called capistrano-passenger.  Just add it to your Gemfile and require it in your Capfile.
eos

  gem.required_ruby_version = '>= 1.9.3'
  gem.add_dependency 'sshkit', '~> 1.3'
  gem.add_dependency 'capistrano-stats', '~> 1.1.0'
  gem.add_dependency 'rake', '>= 10.0.0'
  gem.add_dependency 'i18n'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'mocha'
end
