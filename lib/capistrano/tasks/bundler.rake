namespace :deploy do

  desc 'Bundle'
  task :bundle do
    on roles :web do
      within release_path do
        execute :bundle, "--gemfile #{release_path}/Gemfile --deployment --binstubs #{shared_path}/bin --path #{shared_path}/bundle --without development test cucumber"
      end
    end
  end

  after :update, :bundle
end
