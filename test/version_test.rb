require "#{File.dirname(__FILE__)}/utils"
require 'capistrano/version'

class VersionTest < Test::Unit::TestCase
  def test_check_should_return_true_for_matching_parameters
    assert Capistrano::Version.check([2], [2])
    assert Capistrano::Version.check([2,1], [2,1])
    assert Capistrano::Version.check([2,1,5], [2,1,5])
  end

  def test_check_should_return_true_if_first_is_less_than_second
    assert Capistrano::Version.check([2], [3])
    assert Capistrano::Version.check([2], [2,1])
    assert Capistrano::Version.check([2,1], [2,2])
    assert Capistrano::Version.check([2,1], [2,1,1])
  end

  def test_check_should_return_false_if_first_is_greater_than_second
    assert !Capistrano::Version.check([3], [2])
    assert !Capistrano::Version.check([3,1], [3])
    assert !Capistrano::Version.check([3,2], [3,1])
    assert !Capistrano::Version.check([3,2,1], [3,2])
  end
end
