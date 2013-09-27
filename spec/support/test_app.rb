require 'fileutils'
module TestApp
  extend self

  def install
    install_test_app_with(default_config)
  end

  def default_config
    %{
      set :stage, :#{stage}
      set :deploy_to, '#{deploy_to}'
      set :repo_url, 'git://github.com/capistrano/capistrano.git'
      set :branch, 'v3'
      set :ssh_options, { keys: "\#{ENV['HOME']}/.vagrant.d/insecure_private_key" }
      server 'vagrant@localhost:2220', roles: %w{web app}
      set :linked_files, #{linked_files}
      set :linked_dirs, #{linked_dirs}
    }
  end

  def linked_files
    %w{config/database.yml}
  end

  def linked_file
    shared_path.join(linked_files.first)
  end

  def linked_dirs
    %w{bin log public/system vendor/bundle}
  end

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
    Pathname.new('/home/vagrant/var/www/deploy')
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
    releases_path.join(timestamp)
  end

  def timestamp
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def repo_path
    deploy_to.join('repo')
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
