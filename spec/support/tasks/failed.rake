after "deploy:failed", :custom_failed do
  on roles :all do
    execute :touch, shared_path.join("failed")
  end
end
