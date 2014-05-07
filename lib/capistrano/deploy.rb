require 'capistrano/framework'

# Fetches the currently deployed releases. Can be overwritten by setting :releases to a
# different lambda.
#
# Example (inside a task)
#
#   releases = fetch(:releases).call(self)
#   # => ["20140507122109", "20140507122237", "20140507122531"]
#
# Returns an array of folder names inside the releases_path, sorted oldest first.
set :releases, lambda { |context|
  context.capture(:ls, "-xt #{context.releases_path}").split.sort
}

load File.expand_path("../tasks/deploy.rake", __FILE__)
