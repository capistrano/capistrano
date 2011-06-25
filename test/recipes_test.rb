require 'utils'
require 'capistrano/configuration'

class RecipesTest < Test::Unit::TestCase

  def setup
    @config = Capistrano::Configuration.new
    @config.stubs(:logger).returns(stub_everything)
  end

  def test_current_releases_does_not_cause_error_on_dry_run
    @config.dry_run = true
    @config.load 'deploy'
    @config.load do
      set :application, "foo"
      task :dry_run_test do
        fetch :current_release
      end
    end

    assert_nothing_raised do
      @config.dry_run_test
    end
  end
end