# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capistrano/version"

Gem::Specification.new do |s|
  s.name        = "capistrano"
  s.version     = Capistrano::Version.to_s
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jamis Buck", "Lee Hambley"]
  s.email       = ["jamis@jamisbuck.org", "lee.hambley@gmail.com"]
  s.homepage    = "http://github.com/capistrano/capistrano"
  s.summary     = %q{Capistrano - Welcome to easy deployment with Ruby over SSH}
  s.description = %q{Capistrano is a utility and framework for executing commands in parallel on multiple remote machines, via SSH.}
  s.date        = %q{2011-03-22}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = [
    "README.mdown"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3
    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0.14"])
      s.add_runtime_dependency(%q<net-sftp>, [">= 2.0.0"])
      s.add_runtime_dependency(%q<net-scp>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<net-ssh-gateway>, [">= 1.1.0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<net-ssh>, [">= 2.0.14"])
      s.add_dependency(%q<net-sftp>, [">= 2.0.0"])
      s.add_dependency(%q<net-scp>, [">= 1.0.0"])
      s.add_dependency(%q<net-ssh-gateway>, [">= 1.1.0"])
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<net-ssh>, [">= 2.0.14"])
    s.add_dependency(%q<net-sftp>, [">= 2.0.0"])
    s.add_dependency(%q<net-scp>, [">= 1.0.0"])
    s.add_dependency(%q<net-ssh-gateway>, [">= 1.1.0"])
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
