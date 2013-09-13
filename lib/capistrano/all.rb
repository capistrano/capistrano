require 'rake'
require 'sshkit'
require 'sshkit/dsl'

Rake.application.options.trace = true

require 'capistrano/version'
require 'capistrano/version_validator'
require 'capistrano/i18n'
require 'capistrano/dsl'
require 'capistrano/application'
require 'capistrano/configuration'

module Capistrano

end
