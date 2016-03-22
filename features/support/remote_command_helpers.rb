module RemoteCommandHelpers
  def test_dir_exists(path)
    exists?("d", path)
  end

  def test_symlink_exists(path)
    exists?("L", path)
  end

  def test_file_exists(path)
    exists?("f", path)
  end

  def exists?(type, path)
    %Q{[ -#{type} "#{path}" ]}
  end

  def safely_remove_file(_path)
    run_vagrant_command("rm #{test_file}")
  rescue
    VagrantHelpers::VagrantSSHCommandError
  end
end

World(RemoteCommandHelpers)
