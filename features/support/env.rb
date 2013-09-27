require 'kuroko'

project_root = File.expand_path('../../../', __FILE__)
vagrant_root = File.join(project_root, 'spec/support')

Kuroko.configure do |config|
  config.vagrant_root = 'spec/support'
end

puts vagrant_root.inspect

require_relative '../../spec/support/test_app'
