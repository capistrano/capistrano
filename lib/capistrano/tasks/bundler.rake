namespace :deploy do

  desc 'Bundle'
  task :bundle do
    on roles :all do
      within release_path do
        if fetch(:bundle_binstubs) then
          set :binstub_cmd, "--binstubs #{shared_path}/bin"
        end
        execute :bundle, "--gemfile #{release_path}/Gemfile --deployment #{binstub_cmd} --path #{shared_path}/bundle --without development test cucumber"
      end
    end
  end

  before 'deploy:updated', 'deploy:bundle'
end
