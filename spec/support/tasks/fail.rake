set :fail, proc { fail }
before "deploy:starting", :fail do
  on roles :all do
    execute :mkdir, "-p", shared_path
    execute :touch, shared_path.join("fail")
  end
  fetch(:fail)
end
