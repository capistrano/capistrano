require './lib/capistrano/version'

Gem::Specification.new do |s|

  s.name = 'capistrano'
  s.version = PKG_VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = <<-DESC.strip.gsub(/\n\s+/, " ")
    Capistrano is a utility and framework for executing commands in parallel
    on multiple remote machines, via SSH.
  DESC

  s.files = Dir.glob("{bin,lib,examples,test}/**/*") + %w(README MIT-LICENSE CHANGELOG)
  s.require_path = 'lib'
  s.autorequire = 'capistrano'

  s.bindir = "bin"
  s.executables << "cap" << "capify"

  s.add_dependency 'net-ssh', ">= #{Capistrano::Version::SSH_REQUIRED.join(".")}"
  s.add_dependency 'net-sftp', ">= #{Capistrano::Version::SFTP_REQUIRED.join(".")}"
  s.add_dependency 'highline'

  s.author = "Jamis Buck"
  s.email = "jamis@37signals.com"
  s.homepage = "http://www.capify.org"

end
