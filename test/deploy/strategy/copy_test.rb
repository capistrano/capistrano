require "#{File.dirname(__FILE__)}/../../utils"
require 'capistrano/logger'
require 'capistrano/recipes/deploy/strategy/copy'
require 'stringio'

class DeployStrategyCopyTest < Test::Unit::TestCase
  def setup
    @config = { :logger => Capistrano::Logger.new(:output => StringIO.new),
                :releases_path => "/u/apps/test/releases",
                :release_path => "/u/apps/test/releases/1234567890",
                :real_revision => "154" }
    @source = mock("source")
    @config.stubs(:source).returns(@source)
    @strategy = Capistrano::Deploy::Strategy::Copy.new(@config)
  end

  def test_deploy_with_defaults_should_use_tar_gz_and_checkout
    Dir.expects(:tmpdir).returns("/temp/dir")
    Dir.expects(:chdir).with("/temp/dir").yields
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)

    @strategy.expects(:system).with(:local_checkout)
    @strategy.expects(:system).with("tar czf 1234567890.tar.gz 1234567890")
    @strategy.expects(:put).with(:mock_file_contents, "/tmp/1234567890.tar.gz")
    @strategy.expects(:run).with("cd /u/apps/test/releases && tar xzf /tmp/1234567890.tar.gz && rm /tmp/1234567890.tar.gz")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)
    File.expects(:open).with("/temp/dir/1234567890.tar.gz", "rb").yields(StringIO.new).returns(:mock_file_contents)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.tar.gz")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end

  def test_deploy_with_export_should_use_tar_gz_and_export
    Dir.expects(:tmpdir).returns("/temp/dir")
    Dir.expects(:chdir).with("/temp/dir").yields
    @config[:copy_strategy] = :export
    @source.expects(:export).with("154", "/temp/dir/1234567890").returns(:local_export)

    @strategy.expects(:system).with(:local_export)
    @strategy.expects(:system).with("tar czf 1234567890.tar.gz 1234567890")
    @strategy.expects(:put).with(:mock_file_contents, "/tmp/1234567890.tar.gz")
    @strategy.expects(:run).with("cd /u/apps/test/releases && tar xzf /tmp/1234567890.tar.gz && rm /tmp/1234567890.tar.gz")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)
    File.expects(:open).with("/temp/dir/1234567890.tar.gz", "rb").yields(StringIO.new).returns(:mock_file_contents)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.tar.gz")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end

  def test_deploy_with_zip_should_use_zip_and_checkout
    Dir.expects(:tmpdir).returns("/temp/dir")
    Dir.expects(:chdir).with("/temp/dir").yields
    @config[:copy_compression] = :zip
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)

    @strategy.expects(:system).with(:local_checkout)
    @strategy.expects(:system).with("zip -qr 1234567890.zip 1234567890")
    @strategy.expects(:put).with(:mock_file_contents, "/tmp/1234567890.zip")
    @strategy.expects(:run).with("cd /u/apps/test/releases && unzip -q /tmp/1234567890.zip && rm /tmp/1234567890.zip")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)
    File.expects(:open).with("/temp/dir/1234567890.zip", "rb").yields(StringIO.new).returns(:mock_file_contents)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.zip")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end

  def test_deploy_with_bzip2_should_use_zip_and_checkout
    Dir.expects(:tmpdir).returns("/temp/dir")
    Dir.expects(:chdir).with("/temp/dir").yields
    @config[:copy_compression] = :bzip2
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)

    @strategy.expects(:system).with(:local_checkout)
    @strategy.expects(:system).with("tar cjf 1234567890.tar.bz2 1234567890")
    @strategy.expects(:put).with(:mock_file_contents, "/tmp/1234567890.tar.bz2")
    @strategy.expects(:run).with("cd /u/apps/test/releases && tar xjf /tmp/1234567890.tar.bz2 && rm /tmp/1234567890.tar.bz2")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)
    File.expects(:open).with("/temp/dir/1234567890.tar.bz2", "rb").yields(StringIO.new).returns(:mock_file_contents)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.tar.bz2")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end

  def test_deploy_with_custom_copy_dir_should_use_that_as_tmpdir
    Dir.expects(:tmpdir).never
    Dir.expects(:chdir).with("/other/path").yields
    @config[:copy_dir] = "/other/path"
    @source.expects(:checkout).with("154", "/other/path/1234567890").returns(:local_checkout)

    @strategy.expects(:system).with(:local_checkout)
    @strategy.expects(:system).with("tar czf 1234567890.tar.gz 1234567890")
    @strategy.expects(:put).with(:mock_file_contents, "/tmp/1234567890.tar.gz")
    @strategy.expects(:run).with("cd /u/apps/test/releases && tar xzf /tmp/1234567890.tar.gz && rm /tmp/1234567890.tar.gz")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/other/path/1234567890/REVISION", "w").yields(mock_file)
    File.expects(:open).with("/other/path/1234567890.tar.gz", "rb").yields(StringIO.new).returns(:mock_file_contents)

    FileUtils.expects(:rm).with("/other/path/1234567890.tar.gz")
    FileUtils.expects(:rm_rf).with("/other/path/1234567890")

    @strategy.deploy!
  end

  def test_deploy_with_copy_remote_dir_should_copy_to_that_dir
    @config[:copy_remote_dir] = "/somewhere/else"
    Dir.expects(:tmpdir).returns("/temp/dir")
    Dir.expects(:chdir).yields
    @source.expects(:checkout).returns(:local_checkout)

    @strategy.expects(:system).with(:local_checkout)
    @strategy.expects(:system).with("tar czf 1234567890.tar.gz 1234567890")
    @strategy.expects(:put).with(:mock_file_contents, "/somewhere/else/1234567890.tar.gz")
    @strategy.expects(:run).with("cd /u/apps/test/releases && tar xzf /somewhere/else/1234567890.tar.gz && rm /somewhere/else/1234567890.tar.gz")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)
    File.expects(:open).with("/temp/dir/1234567890.tar.gz", "rb").yields(StringIO.new).returns(:mock_file_contents)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.tar.gz")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end
end
