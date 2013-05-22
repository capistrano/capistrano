require "utils"
require 'capistrano/recipes/deploy/scm/subversion'

class DeploySCMSubversionTest < Test::Unit::TestCase
  class TestSCM < Capistrano::Deploy::SCM::Subversion
    default_command "svn"
  end

  def setup
    @config = { :repository => "." }
    def @config.exists?(name); key?(name); end

    @source = TestSCM.new(@config)
  end

  def test_query_revision
    revision = @source.query_revision('HEAD') do |o|
      assert_equal "svn info .  -rHEAD", o
      %Q{Path: rails_2_3
URL: svn+ssh://example.com/var/repos/project/branches/rails_2_3
Repository Root: svn+ssh://example.com/var/repos
Repository UUID: 2d86388d-c40f-0410-ad6a-a69da6a65d20
Revision: 2095
Node Kind: directory
Last Changed Author: sw
Last Changed Rev: 2064
Last Changed Date: 2009-03-11 11:04:25 -0700 (Wed, 11 Mar 2009)
}
    end
    assert_equal 2095, revision
  end

  def test_sync
    @config[:repository] = "http://svn.github.com/capistrano/capistrano.git"
    rev = '602'
    dest = "/var/www"
    assert_equal "svn switch -q  -r602 http://svn.github.com/capistrano/capistrano.git /var/www", @source.sync(rev, dest)
  end

  def test_sends_password_if_set
    require 'capistrano/logger'
    text = "password:"
    @config[:scm_password] = "opensesame"
    assert_equal %("opensesame"\n), @source.handle_data(mock_state, :test_stream, text)
  end

  def test_prompt_password
    require 'capistrano/logger'
    require 'capistrano/cli'
    Capistrano::CLI.stubs(:password_prompt).returns("opensesame")

    text = 'password:'
    assert_equal %("opensesame"\n), @source.handle_data(mock_state, :test_stream, text)
  end

  def test_sends_passphrase
    require 'capistrano/logger'
    text = 'passphrase:'
    @config[:scm_passphrase] = "opensesame"
    assert_equal %("opensesame"\n), @source.handle_data(mock_state, :test_stream, text)
  end

  private

    def mock_state
      { :channel => { :host => "abc" } }
    end
end
