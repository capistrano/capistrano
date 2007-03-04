# set :user, "flippy"
# set :password, "hello-flippy"
# set :gateway, "gateway.example.com"

role :web, "web1.example.com"
role :app, "app1.example.com", "app2.example.com"

desc <<-DESC
This is a sample task. It is only intended to be used as a demonstration of \
how you can define your own tasks.
DESC
task :sample_task, :roles => :app do
  run "ls -l"
end
