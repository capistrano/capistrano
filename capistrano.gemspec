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

  gem.post_install_message = "If you're updating Capistrano from 2.x.x, we recommend you to read the upgrade guide: http://www.capistranorb.com/documentation/upgrading/"

  #gem.signing_key = '/Volumes/SD Card/leehambley-private_key.pem'
  #gem.cert_chain  = ['capistrano-public_cert.pem', 'leehambley-public_cert.pem']

  gem.add_dependency 'sshkit', '>= 0.0.23'
  gem.add_dependency 'rake', '>= 10.0.0'
  gem.add_dependency 'i18n'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'vagrant', '~> 1.0.7'
  gem.add_development_dependency 'kuroko'
  gem.add_development_dependency 'cucumber'

end
