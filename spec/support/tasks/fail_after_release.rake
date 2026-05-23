after "deploy:updated", :fail_after_release do
  on release_roles(:all) do
    execute :touch, release_path.join("fail")
  end

  raise "failure after release"
end
