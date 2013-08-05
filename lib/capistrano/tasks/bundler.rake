namespace :deploy do

  desc 'Bundle'
  task :bundle do
    on roles :all do
      within release_path do
        if bundle_binstubs then
          execute :bundle, "--gemfile #{release_path}/Gemfile --deployment --binstubs #{shared_path}/bin --path #{shared_path}/bundle --without development test cucumber"
        else
          execute :bundle, "--gemfile #{release_path}/Gemfile --deployment --path #{shared_path}/bundle --without development test cucumber"
        end   
      end
    end
  end

  before 'deploy:updated', 'deploy:bundle'
end
