require 'erb'
require 'pathname'
desc 'Install Capistrano, cap install STAGES=staging,production'
task :install do
  envs = ENV['STAGES'] || 'staging,production'

  tasks_dir = Pathname.new('lib/capistrano/tasks')
  config_dir = Pathname.new('config')
  deploy_dir = config_dir.join('deploy')

  deploy_rb = File.expand_path("../../templates/deploy.rb.erb", __FILE__)
  stage_rb = File.expand_path("../../templates/stage.rb.erb", __FILE__)
  capfile = File.expand_path("../../templates/Capfile", __FILE__)

  mkdir_p deploy_dir

  template = File.read(deploy_rb)
  file = config_dir.join('deploy.rb')
  File.open(file, 'w+') do |f|
    f.write(ERB.new(template).result(binding))
    puts I18n.t(:written_file, scope: :capistrano, file: file)
  end

  template = File.read(stage_rb)
  envs.split(',').each do |stage|
    file = deploy_dir.join("#{stage}.rb")
    File.open(file, 'w+') do |f|
      f.write(ERB.new(template).result(binding))
      puts I18n.t(:written_file, scope: :capistrano, file: file)
    end
  end

  mkdir_p tasks_dir

  FileUtils.cp(capfile, 'Capfile')


  puts I18n.t :capified, scope: :capistrano
end
