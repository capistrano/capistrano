# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano"
  gem.version       = Capistrano::VERSION
  gem.authors       = ["Tom Clements"]
  gem.email         = ["seenmyfate@gmail.com"]
  gem.description   = %q{PENDING: Write a gem description}
  gem.summary       = %q{PENDING: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = 'cap'
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.signing_key = '/Volumes/SD Card/leehambley-private_key.pem'
  gem.cert_chain  = ['capistrano-public_cert.pem', 'leehambley-public_cert.pem']

  gem.add_dependency 'sshkit', '>= 0.0.23'
  gem.add_dependency 'rake', '>= 10.0.0'
  gem.add_dependency 'i18n'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'mocha'

end
