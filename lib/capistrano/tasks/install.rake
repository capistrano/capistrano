require "erb"
require "pathname"
desc "Install Capistrano, cap install STAGES=staging,production"
task :install do
  envs = ENV["STAGES"] || "staging,production"

  tasks_dir = Pathname.new("lib/capistrano/tasks")
  config_dir = Pathname.new("config")
  deploy_dir = config_dir.join("deploy")

  deploy_rb = File.expand_path("../../templates/deploy.rb.erb", __FILE__)
  stage_rb = File.expand_path("../../templates/stage.rb.erb", __FILE__)
  capfile = File.expand_path("../../templates/Capfile", __FILE__)

  mkdir_p deploy_dir

  entries = [{ template: deploy_rb, file: config_dir.join("deploy.rb") }]
  entries += envs.split(",").map { |stage| { template: stage_rb, file: deploy_dir.join("#{stage}.rb") } }

  entries.each do |entry|
    if File.exist?(entry[:file])
      warn "[skip] #{entry[:file]} already exists"
    else
      File.open(entry[:file], "w+") do |f|
        f.write(ERB.new(File.read(entry[:template])).result(binding))
        puts I18n.t(:written_file, scope: :capistrano, file: entry[:file])
      end
    end
  end

  mkdir_p tasks_dir

  if File.exist?("Capfile")
    warn "[skip] Capfile already exists"
  else
    FileUtils.cp(capfile, "Capfile")
    puts I18n.t(:written_file, scope: :capistrano, file: "Capfile")
  end

  puts I18n.t :capified, scope: :capistrano
end
