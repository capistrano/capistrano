unless defined?(TestExtensions)
  $:.unshift "#{File.dirname(__FILE__)}/../lib"

  require 'test/unit'
  require 'mocha'
  require 'capistrano/server_definition'

  module TestExtensions
    def server(host, options={})
      Capistrano::ServerDefinition.new(host, options)
    end
  end

  class Test::Unit::TestCase
    include TestExtensions
  end
end