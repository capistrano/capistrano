require 'rake'
require 'sshkit'

Rake.application.options.trace = true

require 'capistrano/version'
require 'capistrano/i18n'
require 'capistrano/dsl'
require 'capistrano/application'
require 'capistrano/configuration'

module Capistrano
end
