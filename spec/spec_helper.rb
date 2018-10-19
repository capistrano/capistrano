$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require "capistrano/all"
require "rspec"
require "mocha/api"
require "time"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir['#{File.dirname(__FILE__)}/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_framework = :mocha
  config.order = "random"

  config.around(:example, capture_io: true) do |example|
    begin
      Rake.application.options.trace_output = StringIO.new
      $stdout = StringIO.new
      $stderr = StringIO.new
      example.run
    ensure
      Rake.application.options.trace_output = STDERR
      $stdout = STDOUT
      $stderr = STDERR
    end
  end
end
