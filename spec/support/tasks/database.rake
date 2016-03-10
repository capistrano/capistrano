namespace :deploy do
  namespace :check do
    task linked_files: "config/database.yml"
  end
end

remote_file "config/database.yml" => "/tmp/database.yml", :roles => :all

file "/tmp/database.yml" do |t|
  sh "touch #{t.name}"
end
