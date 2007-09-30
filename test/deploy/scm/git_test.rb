require "#{File.dirname(__FILE__)}/../../utils"
require 'capistrano/recipes/deploy/scm/git'

class DeploySCMGitTest < Test::Unit::TestCase
  class TestSCM < Capistrano::Deploy::SCM::Git
    default_command "git"
  end

  def setup
    @config = { }
    def @config.exists?(name); key?(name); end

    @source = TestSCM.new(@config)
  end

  def test_head
    assert_equal "HEAD", @source.head
    @config[:branch] = "master"
    assert_equal "master", @source.head
  end

  def test_checkout
    @config[:repository] = "git@somehost.com:project.git"
    dest = "/var/www"
    assert_equal "git clone git@somehost.com:project.git /var/www && cd /var/www && git checkout -b deploy HEAD", @source.checkout('Not used', dest)

    # With branch
    @config[:branch] = "origin/foo"
    assert_equal "git clone git@somehost.com:project.git /var/www && cd /var/www && git checkout -b deploy origin/foo", @source.checkout('Not used', dest)
  end

  def test_diff
    assert_equal "git diff master", @source.diff('master')
    assert_equal "git diff master..branch", @source.diff('master', 'branch')
  end

  def test_log
    assert_equal "git log master", @source.log('master')
    assert_equal "git log master..branch", @source.log('master', 'branch')
  end

  def test_query_revision
    assert_equal "git rev-parse HEAD", @source.query_revision('HEAD') { |o| o }
  end

  def test_command_should_be_backwards_compatible
    # 1.x version of this module used ":git", not ":scm_command"
    @config[:git] = "/srv/bin/git"
    assert_equal "/srv/bin/git", @source.command
  end

  def test_sync
    dest = "/var/www"
    assert_equal "cd #{dest} && git fetch origin && git merge origin/HEAD", @source.sync('Not used', dest)

    # With branch
    @config[:branch] = "origin/foo"
    assert_equal "cd #{dest} && git fetch origin && git merge origin/foo", @source.sync('Not used', dest)
  end

  def test_shallow_clone
    @config[:repository] = "git@somehost.com:project.git"
    @config[:git_shallow_clone] = 1
    dest = "/var/www"
    assert_equal "git clone --depth 1 git@somehost.com:project.git /var/www && cd /var/www && git checkout -b deploy HEAD", @source.checkout('Not used', dest)

    # With branch
    @config[:branch] = "origin/foo"
    assert_equal "git clone --depth 1 git@somehost.com:project.git /var/www && cd /var/www && git checkout -b deploy origin/foo", @source.checkout('Not used', dest)
  end

  # Tests from base_test.rb, makin' sure we didn't break anything up there!
  def test_command_should_default_to_default_command
    assert_equal "git", @source.command
    @source.local { assert_equal "git", @source.command }
  end

  def test_command_should_use_scm_command_if_available
    @config[:scm_command] = "/opt/local/bin/git"
    assert_equal "/opt/local/bin/git", @source.command
  end

  def test_command_should_use_scm_command_in_local_mode_if_local_scm_command_not_set
    @config[:scm_command] = "/opt/local/bin/git"
    @source.local { assert_equal "/opt/local/bin/git", @source.command }
  end

  def test_command_should_use_local_scm_command_in_local_mode_if_local_scm_command_is_set
    @config[:scm_command] = "/opt/local/bin/git"
    @config[:local_scm_command] = "/usr/local/bin/git"
    assert_equal "/opt/local/bin/git", @source.command
    @source.local { assert_equal "/usr/local/bin/git", @source.command }
  end

  def test_command_should_use_default_if_scm_command_is_default
    @config[:scm_command] = :default
    assert_equal "git", @source.command
  end

  def test_command_should_use_default_in_local_mode_if_local_scm_command_is_default
    @config[:scm_command] = "/foo/bar/git"
    @config[:local_scm_command] = :default
    @source.local { assert_equal "git", @source.command }
  end

  def test_local_mode_proxy_should_treat_messages_as_being_in_local_mode
    @config[:scm_command] = "/foo/bar/git"
    @config[:local_scm_command] = :default
    assert_equal "git", @source.local.command
    assert_equal "/foo/bar/git", @source.command
  end
end
