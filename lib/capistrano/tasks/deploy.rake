namespace :deploy do

  desc "Setup"
  task :setup do
    puts 'setup'
  end

  desc "Start the deployment"
  task :start do
    puts 'start'
  end

  desc "The actual work"
  task :work do
    puts 'work'
  end

  desc "Finish the deployment"
  task :finish do
    puts 'finish'
  end

  desc "Tear down"
  task :teardown do
    puts 'tear down'
  end
end

desc "Deploy"
task :deploy do
  [:setup, :start, :work, :finish, :teardown].each do |stage|
    Rake::Task["deploy:#{stage}"].invoke
  end
end
task default: :deploy


