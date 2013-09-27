module RemoteCommandHelpers

  def test_dir_exists(path)
    exists?('d', path)
  end

  def test_symlink_exists(path)
    exists?('L', path)
  end

  def test_file_exists(path)
    exists?('f', path)
  end

  def exists?(type, path)
    %{[ -#{type} "#{path}" ] && echo "#{path} exists." || echo "Error: #{path} does not exist."}
  end
end

World(RemoteCommandHelpers)
