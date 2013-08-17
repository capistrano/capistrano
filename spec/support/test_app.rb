require 'fileutils'
module TestApp
  def create_test_app
    [test_app_path, deploy_to].each do |path|
      FileUtils.rm_rf(path)
      FileUtils.mkdir(path)
    end

    File.open(gemfile, 'w+') do |file|
      file.write "gem 'capistrano', path: '#{path_to_cap}'"
    end

    Dir.chdir(test_app_path) do
      %x[bundle]
    end
  end

  def install_test_app_with(config)
    create_test_app
    Dir.chdir(test_app_path) do
      %x[bundle exec cap install STAGES=#{stage}]
    end
    write_local_deploy_file(config)
  end

  def write_local_deploy_file(config)
    File.open(test_stage_path, 'w') do |file|
      file.write config
    end
  end

  def create_shared_directory(path)
    FileUtils.mkdir_p(shared_path.join(path))
  end

  def create_shared_file(path)
    File.open(shared_path.join(path), 'w')
  end

  def cap(task)
    Dir.chdir(test_app_path) do
      %x[bundle exec cap #{stage} #{task}]
    end
  end

  def stage
    'test'
  end

  def test_stage_path
    test_app_path.join('config/deploy/test.rb')
  end

  def test_app_path
    Pathname.new('/tmp/test_app')
  end

  def deploy_to
    Pathname.new('/tmp/test_app/deploy_to')
  end

  def shared_path
    deploy_to.join('shared')
  end

  def current_path
    deploy_to.join('current')
  end

  def releases_path
    deploy_to.join('releases')
  end

  def release_path
    releases_path.join(Dir.entries(releases_path).last)
  end

  def path_to_cap
    File.expand_path('.')
  end

  def gemfile
    test_app_path.join('Gemfile')
  end

  def capfile
    test_app_path.join('Capfile')
  end

  def current_user
    `whoami`.chomp
  end

  def task_dir
    test_app_path.join('lib/capistrano/tasks')
  end

  def copy_task_to_test_app(source)
    FileUtils.cp(source, task_dir)
  end
end
