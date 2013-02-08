require 'erb'
desc 'Install Capistrano, cap install STAGES=staging,production'
task :install do
  envs = ENV['STAGES'] || 'staging,production'

  tasks_dir = 'lib/deploy/tasks'
  config_dir = 'config/deploy'

  deploy_rb = File.read(File.expand_path("../../templates/deploy.rb.erb", __FILE__))
  capfile = File.expand_path("../../templates/Capfile", __FILE__)

  envs.split(',').each do |stage|
    File.open("#{config_dir}/#{stage}.rb", 'w+') do |f|
      f.write(ERB.new(deploy_rb).result(binding))
    end
  end

  FileUtils.cp(capfile, 'Capfile')

  mkdir_p tasks_dir

  puts I18n.t :capified, scope: :capistrano
end
