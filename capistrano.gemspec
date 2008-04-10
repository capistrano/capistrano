Gem::Specification.new do |s|

  s.name = 'capistrano'
  s.version = PKG_VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = <<-DESC.strip.gsub(/\n\s+/, " ")
    Capistrano is a utility and framework for executing commands in parallel
    on multiple remote machines, via SSH.
  DESC

  s.files = Dir.glob("{bin,lib,examples,test}/**/*") + %w(README MIT-LICENSE CHANGELOG)
  s.has_rdoc = true

  s.bindir = "bin"
  s.executables << "cap" << "capify"

  s.add_dependency 'net-ssh', ">= 1.99.2"
  s.add_dependency 'net-sftp', ">= 1.99.1"
  s.add_dependency 'net-ssh-gateway', ">= 0.99.0"
  s.add_dependency 'highline'

  s.author = "Jamis Buck"
  s.email = "jamis@37signals.com"
  s.homepage = "http://www.capify.org"
  s.rubyforge_project = "capistrano"

end
