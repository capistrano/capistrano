desc 'Install Capistrano'
task :install do
  tasks_dir = 'lib/deploy/tasks'
  config_dir = 'config/deploy'

  deploy_rb = File.expand_path("../../templates/deploy.rb", __FILE__)
  capfile = File.expand_path("../../templates/Capfile", __FILE__)

  FileUtils.cp(deploy_rb, 'config/deploy.rb')
  FileUtils.cp(capfile, 'Capfile')

  mkdir_p tasks_dir
  mkdir_p config_dir

  puts 'Capified'
end
