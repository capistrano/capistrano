namespace :github do

  desc 'Notify Github about new deployment'
  task :create_deployment do
    gh = Capistrano::Github.new(fetch(:repo_url), fetch(:github_accesss_token))

    payload = {
      environment: fetch(:rails_env)
    }

    dep = gh.create_deployment(fetch(:branch), force: true, payload: payload)

    target = "http://#{primary(:app).hostname}"
    gh.create_deployment_status(dep.id, :pending, target)
  end

  desc 'List Github deployments'
  task :list_deployments do
    gh = Capistrano::Github.new(fetch(:repo_url), fetch(:github_access_token))
    gh.deployments.each do |d|
      puts "Deployment: #{d.created_at} #{d.sha} by @#{d.creator_login} #{d.payload}"

      d.statuses.each do |s|
        puts "#{s.created_at} state: #{s.state}"
      end
    end
  end

  desc 'Finish Github deployment'
  task :finish_deployment do
    gh = Capistrano::Github.new(fetch(:repo_url))

    target = primary(:app).hostname
    gh.create_deployment_status(dep.id, :failed, target)
  end

end
