module TestApp
  def create_test_app
    FileUtils.rm_rf(test_app_path)
    FileUtils.mkdir(test_app_path)

    File.open(gemfile, 'w+') do |file|
      file.write "gem 'capistrano', path: '#{path_to_cap}'"
    end

    Dir.chdir(test_app_path) do
      %x[bundle]
    end
  end


  def test_app_path
    Pathname.new('/tmp/test_app')
  end

  def path_to_cap
    File.expand_path('.')
  end

  def gemfile
    test_app_path.join('Gemfile')
  end
end
