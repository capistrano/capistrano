require 'capistrano/version'

class VersionTest < Test::Unit::TestCase
  def test_version_constant_is_not_nil
    assert_not_nil Capistrano::VERSION
  end

  def test_version_constant_matches_class_method
    assert_equal Capistrano::VERSION, Capistrano::Version.to_s
  end
end
