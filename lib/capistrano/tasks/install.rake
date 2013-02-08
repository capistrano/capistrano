require 'erb'
desc 'Install Capistrano, cap install STAGES=staging,production'
task :install do
  envs = ENV['STAGES'] || 'staging,production'

  tasks_dir = 'lib/deploy/tasks'
  config_dir = 'config/deploy'

  deploy_rb = File.expand_path("../../templates/deploy.rb.erb", __FILE__)
  capfile = File.expand_path("../../templates/Capfile", __FILE__)

  mkdir_p config_dir

  template = File.read(deploy_rb)
  envs.split(',').each do |stage|
    File.open("#{config_dir}/#{stage}.rb", 'w+') do |f|
      f.write(ERB.new(template).result(binding))
      puts I18n.t(:written_stage_file, scope: :capistrano, stage: stage)
    end
  end

  mkdir_p tasks_dir

  FileUtils.cp(capfile, 'Capfile')


  puts I18n.t :capified, scope: :capistrano
end
