# example configuration
Capistrano::Env.configure do |config|
  config.role :app, %w{example.com}
  config.role :web, %w{example.com}
  config.role :db, %w{example.com}
  config.path '/var/www/my_app/current'
  config.format :pretty # :dot
end
