require "rake"
require "sshkit"

require "io/console"

Rake.application.options.trace = true

require "capistrano/version"
require "capistrano/version_validator"
require "capistrano/i18n"
require "capistrano/dsl"
require "capistrano/application"
require "capistrano/configuration"
require "capistrano/rake_monkey_patch"

module Capistrano
end
