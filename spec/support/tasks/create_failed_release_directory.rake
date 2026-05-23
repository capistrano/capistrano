namespace :deploy do
  task :create_failed_release_directory do
    set_release_path("20150101000000")

    on release_roles(:all) do
      execute :mkdir, "-p", shared_path, releases_path, release_path
    end
  end
end
