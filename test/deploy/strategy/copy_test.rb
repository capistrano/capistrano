require "utils"
require 'capistrano/logger'
require 'capistrano/recipes/deploy/strategy/copy'
require 'stringio'

class DeployStrategyCopyTest < Test::Unit::TestCase
  def setup
    @config = { :application => "captest",
                :releases_path => "/u/apps/test/releases",
                :release_path => "/u/apps/test/releases/1234567890",
                :real_revision => "154" }
    @config.stubs(:logger).returns(stub_everything)

    @source = mock("source")
    @config.stubs(:source).returns(@source)
    @strategy = Capistrano::Deploy::Strategy::Copy.new(@config)
  end

  def test_deploy_with_defaults_should_use_remote_gtar
    @config[:copy_remote_tar] = 'gtar'

    Dir.expects(:tmpdir).returns("/temp/dir")
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)
    @strategy.expects(:system).with(:local_checkout)

    Dir.expects(:chdir).with("/temp/dir").yields
    @strategy.expects(:system).with("tar czf 1234567890.tar.gz 1234567890")
    @strategy.expects(:upload).with("/temp/dir/1234567890.tar.gz", "/tmp/1234567890.tar.gz")
    @strategy.expects(:run).with("cd /u/apps/test/releases && gtar xzf /tmp/1234567890.tar.gz && rm /tmp/1234567890.tar.gz")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.tar.gz")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end

  def test_deploy_with_defaults_should_use_local_gtar
    @config[:copy_local_tar] = 'gtar'

    Dir.expects(:tmpdir).returns("/temp/dir")
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)
    @strategy.expects(:system).with(:local_checkout)

    Dir.expects(:chdir).with("/temp/dir").yields
    @strategy.expects(:system).with("gtar czf 1234567890.tar.gz 1234567890")
    @strategy.expects(:upload).with("/temp/dir/1234567890.tar.gz", "/tmp/1234567890.tar.gz")
    @strategy.expects(:run).with("cd /u/apps/test/releases && tar xzf /tmp/1234567890.tar.gz && rm /tmp/1234567890.tar.gz")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.tar.gz")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end

  def test_deploy_with_defaults_should_use_tar_gz_and_checkout
    Dir.expects(:tmpdir).returns("/temp/dir")
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)
    @strategy.expects(:system).with(:local_checkout)

    prepare_standard_compress_and_copy!
    @strategy.deploy!
  end

  def test_deploy_with_exclusions_should_remove_patterns_from_destination
    @config[:copy_exclude] = ".git"
    Dir.expects(:tmpdir).returns("/temp/dir")
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)
    @strategy.expects(:system).with(:local_checkout)
    Dir.expects(:glob).with("/temp/dir/1234567890/.git", File::FNM_DOTMATCH).returns(%w(/temp/dir/1234567890/.git))

    FileUtils.expects(:rm_rf).with(%w(/temp/dir/1234567890/.git))
    prepare_standard_compress_and_copy!
    @strategy.deploy!
  end

  def test_deploy_with_exclusions_should_remove_glob_patterns_from_destination
    @config[:copy_exclude] = ".gi*"
    Dir.expects(:tmpdir).returns("/temp/dir")
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)
    @strategy.expects(:system).with(:local_checkout)
    Dir.expects(:glob).with("/temp/dir/1234567890/.gi*", File::FNM_DOTMATCH).returns(%w(/temp/dir/1234567890/.git))

    FileUtils.expects(:rm_rf).with(%w(/temp/dir/1234567890/.git))
    prepare_standard_compress_and_copy!
    @strategy.deploy!
  end

  def test_deploy_with_export_should_use_tar_gz_and_export
    Dir.expects(:tmpdir).returns("/temp/dir")
    @config[:copy_strategy] = :export
    @source.expects(:export).with("154", "/temp/dir/1234567890").returns(:local_export)
    @strategy.expects(:system).with(:local_export)

    prepare_standard_compress_and_copy!
    @strategy.deploy!
  end

  def test_deploy_with_zip_should_use_zip_and_checkout
    Dir.expects(:tmpdir).returns("/temp/dir")
    Dir.expects(:chdir).with("/temp/dir").yields
    @config[:copy_compression] = :zip
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)

    @strategy.expects(:system).with(:local_checkout)
    @strategy.expects(:system).with("zip -qyr 1234567890.zip 1234567890")
    @strategy.expects(:upload).with("/temp/dir/1234567890.zip", "/tmp/1234567890.zip")
    @strategy.expects(:run).with("cd /u/apps/test/releases && unzip -q /tmp/1234567890.zip && rm /tmp/1234567890.zip")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.zip")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end

  def test_deploy_with_bzip2_should_use_bz2_and_checkout
    Dir.expects(:tmpdir).returns("/temp/dir")
    Dir.expects(:chdir).with("/temp/dir").yields
    @config[:copy_compression] = :bzip2
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)

    @strategy.expects(:system).with(:local_checkout)
    @strategy.expects(:system).with("tar cjf 1234567890.tar.bz2 1234567890")
    @strategy.expects(:upload).with("/temp/dir/1234567890.tar.bz2", "/tmp/1234567890.tar.bz2")
    @strategy.expects(:run).with("cd /u/apps/test/releases && tar xjf /tmp/1234567890.tar.bz2 && rm /tmp/1234567890.tar.bz2")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.tar.bz2")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end

  def test_deploy_with_unknown_compression_type_should_error
    @config[:copy_compression] = :bogus
    Dir.expects(:tmpdir).returns("/temp/dir")
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)
    @strategy.stubs(:system)
    File.stubs(:open)

    assert_raises(ArgumentError) { @strategy.deploy! }
  end

  def test_deploy_with_custom_copy_dir_should_use_that_as_tmpdir
    Dir.expects(:tmpdir).never
    Dir.expects(:chdir).with("/other/path").yields
    @config[:copy_dir] = "/other/path"
    @source.expects(:checkout).with("154", "/other/path/1234567890").returns(:local_checkout)

    @strategy.expects(:system).with(:local_checkout)
    @strategy.expects(:system).with("tar czf 1234567890.tar.gz 1234567890")
    @strategy.expects(:upload).with("/other/path/1234567890.tar.gz", "/tmp/1234567890.tar.gz")
    @strategy.expects(:run).with("cd /u/apps/test/releases && tar xzf /tmp/1234567890.tar.gz && rm /tmp/1234567890.tar.gz")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/other/path/1234567890/REVISION", "w").yields(mock_file)

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
    @strategy.expects(:upload).with("/temp/dir/1234567890.tar.gz", "/somewhere/else/1234567890.tar.gz")
    @strategy.expects(:run).with("cd /u/apps/test/releases && tar xzf /somewhere/else/1234567890.tar.gz && rm /somewhere/else/1234567890.tar.gz")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.tar.gz")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end

  def test_deploy_with_copy_via_should_use_the_given_transfer_method
    @config[:copy_via] = :scp
    Dir.expects(:tmpdir).returns("/temp/dir")
    Dir.expects(:chdir).yields
    @source.expects(:checkout).returns(:local_checkout)

    @strategy.expects(:system).with(:local_checkout)
    @strategy.expects(:system).with("tar czf 1234567890.tar.gz 1234567890")
    @strategy.expects(:upload).with("/temp/dir/1234567890.tar.gz", "/tmp/1234567890.tar.gz", {:via => :scp})
    @strategy.expects(:run).with("cd /u/apps/test/releases && tar xzf /tmp/1234567890.tar.gz && rm /tmp/1234567890.tar.gz")

    mock_file = mock("file")
    mock_file.expects(:puts).with("154")
    File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)

    FileUtils.expects(:rm).with("/temp/dir/1234567890.tar.gz")
    FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")

    @strategy.deploy!
  end

  def test_with_copy_cache_should_checkout_to_cache_if_cache_does_not_exist_and_then_copy
    @config[:copy_cache] = true

    Dir.stubs(:tmpdir).returns("/temp/dir")
    File.expects(:exists?).with("/temp/dir/captest").returns(false)
    Dir.expects(:chdir).with("/temp/dir/captest").yields

    @source.expects(:checkout).with("154", "/temp/dir/captest").returns(:local_checkout)
    @strategy.expects(:system).with(:local_checkout)

    FileUtils.expects(:mkdir_p).with("/temp/dir/1234567890")

    prepare_directory_tree!("/temp/dir/captest")

    prepare_standard_compress_and_copy!
    @strategy.deploy!
  end

  def test_with_copy_cache_should_update_cache_if_cache_exists_and_then_copy
    @config[:copy_cache] = true

    Dir.stubs(:tmpdir).returns("/temp/dir")
    File.expects(:exists?).with("/temp/dir/captest").returns(true)
    Dir.expects(:chdir).with("/temp/dir/captest").yields

    @source.expects(:sync).with("154", "/temp/dir/captest").returns(:local_sync)
    @strategy.expects(:system).with(:local_sync)

    FileUtils.expects(:mkdir_p).with("/temp/dir/1234567890")

    prepare_directory_tree!("/temp/dir/captest")

    prepare_standard_compress_and_copy!
    @strategy.deploy!
  end

  def test_with_copy_cache_with_custom_absolute_cache_dir_path_should_use_specified_cache_dir
    @config[:copy_cache] = "/u/caches/captest"

    Dir.stubs(:tmpdir).returns("/temp/dir")
    File.expects(:exists?).with("/u/caches/captest").returns(true)
    Dir.expects(:chdir).with("/u/caches/captest").yields

    @source.expects(:sync).with("154", "/u/caches/captest").returns(:local_sync)
    @strategy.expects(:system).with(:local_sync)

    FileUtils.expects(:mkdir_p).with("/temp/dir/1234567890")

    prepare_directory_tree!("/u/caches/captest")

    prepare_standard_compress_and_copy!
    @strategy.deploy!
  end

  def test_with_copy_cache_with_custom_relative_cache_dir_path_should_use_specified_cache_dir
    @config[:copy_cache] = "caches/captest"

    Dir.stubs(:pwd).returns("/u")
    Dir.stubs(:tmpdir).returns("/temp/dir")
    File.expects(:exists?).with("/u/caches/captest").returns(true)
    Dir.expects(:chdir).with("/u/caches/captest").yields

    @source.expects(:sync).with("154", "/u/caches/captest").returns(:local_sync)
    @strategy.expects(:system).with(:local_sync)

    FileUtils.expects(:mkdir_p).with("/temp/dir/1234567890")

    prepare_directory_tree!("/u/caches/captest")

    prepare_standard_compress_and_copy!
    @strategy.deploy!
  end

  def test_with_copy_cache_with_excludes_should_not_copy_excluded_files
    @config[:copy_cache] = true
    @config[:copy_exclude] = "*/bar.txt"

    Dir.stubs(:tmpdir).returns("/temp/dir")
    File.expects(:exists?).with("/temp/dir/captest").returns(true)
    Dir.expects(:chdir).with("/temp/dir/captest").yields

    @source.expects(:sync).with("154", "/temp/dir/captest").returns(:local_sync)
    @strategy.expects(:system).with(:local_sync)

    FileUtils.expects(:mkdir_p).with("/temp/dir/1234567890")

    prepare_directory_tree!("/temp/dir/captest", true)

    prepare_standard_compress_and_copy!
    @strategy.deploy!
  end

  def test_with_build_script_should_run_script
    @config[:build_script] = "mkdir bin"

    Dir.expects(:tmpdir).returns("/temp/dir")
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)
    @strategy.expects(:system).with(:local_checkout)

    Dir.expects(:chdir).with("/temp/dir/1234567890").yields
    @strategy.expects(:system).with("mkdir bin")

    prepare_standard_compress_and_copy!
    @strategy.deploy!
  end

  private

    def prepare_directory_tree!(cache, exclude=false)
      Dir.expects(:glob).with("*", File::FNM_DOTMATCH).returns([".", "..", "app", "app{1}", "foo.txt"])
      File.expects(:ftype).with("app").returns("directory")
      File.expects(:ftype).with("app{1}").returns("directory")
      FileUtils.expects(:mkdir).with("/temp/dir/1234567890/app")
      FileUtils.expects(:mkdir).with("/temp/dir/1234567890/app{1}")
      File.expects(:ftype).with("foo.txt").returns("file")
      FileUtils.expects(:ln).with("foo.txt", "/temp/dir/1234567890/foo.txt")

      Dir.expects(:glob).with("app/*", File::FNM_DOTMATCH).returns(["app/.", "app/..", "app/bar.txt"])
      Dir.expects(:glob).with("app\\{1\\}/*", File::FNM_DOTMATCH).returns(["app{1}/.", "app{1}/.."])

      unless exclude
      File.expects(:ftype).with("app/bar.txt").returns("file")
        FileUtils.expects(:ln).with("app/bar.txt", "/temp/dir/1234567890/app/bar.txt")
      end
    end

    def prepare_standard_compress_and_copy!
      Dir.expects(:chdir).with("/temp/dir").yields
      @strategy.expects(:system).with("tar czf 1234567890.tar.gz 1234567890")
      @strategy.expects(:upload).with("/temp/dir/1234567890.tar.gz", "/tmp/1234567890.tar.gz")
      @strategy.expects(:run).with("cd /u/apps/test/releases && tar xzf /tmp/1234567890.tar.gz && rm /tmp/1234567890.tar.gz")

      mock_file = mock("file")
      mock_file.expects(:puts).with("154")
      File.expects(:open).with("/temp/dir/1234567890/REVISION", "w").yields(mock_file)

      FileUtils.expects(:rm).with("/temp/dir/1234567890.tar.gz")
      FileUtils.expects(:rm_rf).with("/temp/dir/1234567890")
    end
end
