require "utils"
require 'capistrano/recipes/deploy/scm/perforce'

class DeploySCMPerforceTest < Test::Unit::TestCase
  class TestSCM < Capistrano::Deploy::SCM::Perforce
    default_command "perforce"
  end
  def setup
    @config = { :repository => "." }
    @source = TestSCM.new(@config)
  end

  def test_p4_label
    @config[:p4_label] = "some_p4_label"
    assert_equal "@some_p4_label", @source.send(:rev_no, 'foo')
  end

  def test_p4_label_with_symbol
    @config[:p4_label] = "@some_p4_label"
    assert_equal "@some_p4_label", @source.send(:rev_no, 'foo')
  end

end
