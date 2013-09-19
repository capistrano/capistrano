require 'time'
require 'sshkit'

deploy_to = '/opt/sites/capistranorb_com'
release_timestamp = Time.now.utc.strftime("%Y%m%d%H%m%S")

desc "Build Jekyll Site And Sync With S3"
task :deploy do
  sh "bundle exec jekyll build"
  on 'harrow.io' do
    upload! '_site/', deploy_to, recursive: true
    within(deploy_to) do
      execute :mv, '_site/', release_timestamp
      execute :ln, '-snf', release_timestamp, 'public'
    end
  end
end

task :default => :deploy
