after "deploy:published", :fail_after_publish do
  on release_roles(:all) do
    execute :touch, release_path.join("fail")
  end

  raise "failure after publish"
end
