require "./lib/capistrano/version"

begin
  require 'echoe'
rescue LoadError
  abort "You'll need to have `echoe' installed to use Capistrano's Rakefile"
end

version = Capistrano::Version::STRING.dup
if ENV['SNAPSHOT'].to_i == 1
  version << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end

Echoe.new('capistrano', version) do |p|
  p.changelog        = "CHANGELOG.rdoc"

  p.author           = "Jamis Buck"
  p.email            = "jamis@jamisbuck.org"

  p.summary = <<-DESC.strip.gsub(/\n\s+/, " ")
    Capistrano is a utility and framework for executing commands in parallel
    on multiple remote machines, via SSH.
  DESC

  p.url              = "http://www.capify.org"
  p.need_zip         = true
  p.rdoc_pattern     = /^(lib|README.rdoc|CHANGELOG.rdoc)/

  p.dependencies     = ["net-ssh         >=2.0.0",
                        "net-sftp        >=2.0.0",
                        "net-scp         >=1.0.0",
                        "net-ssh-gateway >=1.0.0",
                        "highline"]
end
