require "English"
require "fileutils"
require "pathname"

module TestApp
  extend self

  def install
    install_test_app_with(default_config)
  end

  def default_config
    <<-CONFIG
      set :deploy_to, '#{deploy_to}'
      set :repo_url, 'git://github.com/capistrano/capistrano.git'
      set :branch, 'master'
      set :ssh_options, { keys: "\#{ENV['HOME']}/.vagrant.d/insecure_private_key", auth_methods: ['publickey'] }
      server 'vagrant@localhost:2220', roles: %w{web app}
      set :linked_files, #{linked_files}
      set :linked_dirs, #{linked_dirs}
      set :format_options, log_file: nil
      set :local_user, #{current_user.inspect}
    CONFIG
  end

  def linked_files
    %w{config/database.yml}
  end

  def linked_file
    shared_path.join(linked_files.first)
  end

  def linked_dirs
    %w{bin log public/system}
  end

  def create_test_app
    FileUtils.rm_rf(test_app_path)
    FileUtils.mkdir(test_app_path)

    File.open(gemfile, "w+") do |file|
      file.write "gem 'capistrano', path: '#{path_to_cap}'"
    end

    Dir.chdir(test_app_path) do
      run "bundle"
    end
  end

  def install_test_app_with(config)
    create_test_app
    Dir.chdir(test_app_path) do
      run "cap install STAGES=#{stage}"
    end
    write_local_deploy_file(config)
  end

  def write_local_deploy_file(config)
    File.open(test_stage_path, "w") do |file|
      file.write config
    end
  end

  def write_local_stage_file(filename, config=nil)
    File.open(test_app_path.join("config/deploy/#{filename}"), "w") do |file|
      file.write(config) if config
    end
  end

  def append_to_deploy_file(config)
    File.open(test_stage_path, "a") do |file|
      file.write config + "\n"
    end
  end

  def prepend_to_capfile(config)
    current_capfile = File.read(capfile)
    File.open(capfile, "w") do |file|
      file.write config
      file.write current_capfile
    end
  end

  def create_shared_directory(path)
    FileUtils.mkdir_p(shared_path.join(path))
  end

  def create_shared_file(path)
    File.open(shared_path.join(path), "w")
  end

  def cap(task, subdirectory=nil)
    run "cap #{stage} #{task} --trace", subdirectory
  end

  def run(command, subdirectory=nil)
    output = nil
    command = "bundle exec #{command}" unless command =~ /^bundle\b/
    dir = subdirectory ? test_app_path.join(subdirectory) : test_app_path
    Dir.chdir(dir) do
      output = with_clean_bundler_env { `#{command}` }
    end
    [$CHILD_STATUS.success?, output]
  end

  def stage
    "test"
  end

  def test_stage_path
    test_app_path.join("config/deploy/test.rb")
  end

  def test_app_path
    Pathname.new("/tmp/test_app")
  end

  def deploy_to
    Pathname.new("/home/vagrant/var/www/deploy")
  end

  def shared_path
    deploy_to.join("shared")
  end

  def current_path
    deploy_to.join("current")
  end

  def releases_path
    deploy_to.join("releases")
  end

  def release_path(t=timestamp)
    releases_path.join(t)
  end

  def timestamp(offset=0)
    (Time.now.utc + offset).strftime("%Y%m%d%H%M%S")
  end

  def repo_path
    deploy_to.join("repo")
  end

  def path_to_cap
    File.expand_path(".")
  end

  def gemfile
    test_app_path.join("Gemfile")
  end

  def capfile
    test_app_path.join("Capfile")
  end

  def current_user
    "(GitHub Web Flow) via ShipIt"
  end

  def task_dir
    test_app_path.join("lib/capistrano/tasks")
  end

  def copy_task_to_test_app(source)
    FileUtils.cp(source, task_dir)
  end

  def config_path
    test_app_path.join("config")
  end

  def move_configuration_to_custom_location(location)
    prepend_to_capfile(
      <<-CONFIG
        set :stage_config_path, "app/config/deploy"
        set :deploy_config_path, "app/config/deploy.rb"
      CONFIG
    )

    location = test_app_path.join(location)
    FileUtils.mkdir_p(location)
    FileUtils.mv(config_path, location)
  end

  def git_wrapper_path_glob
    "/tmp/git-ssh-*.sh"
  end

  def with_clean_bundler_env(&block)
    return yield unless defined?(Bundler)

    if Bundler.respond_to?(:with_unbundled_env)
      Bundler.with_unbundled_env(&block)
    else
      Bundler.with_clean_env(&block)
    end
  end
end
