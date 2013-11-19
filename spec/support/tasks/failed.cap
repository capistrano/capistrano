after 'deploy:failed', :failed do
  on roles :all do
    execute :touch, shared_path.join('failed')
  end
end
