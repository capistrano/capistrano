namespace :deploy do

  after :update, :bundle do
    on roles :all do
      within release_path do
        with fetch(:default_environment) do
          execute :bundle, "--gemfile #{release_path}/Gemfile --deployment --binstubs #{shared_path}/bin --path #{shared_path}/bundle --without development test cucumber"
        end
      end
    end
  end
end
