namespace :svn do
  desc 'Check that the repository is reachable'
  task :check do
    on roles(:all) do
      execute :svn, :info, repo_url
    end
  end

  desc 'Copy repo to releases'
  task :create_release do
    ask(:svn_location, "trunk")
    on roles(:all) do
      execute :svn, :export, "#{repo_url}/#{fetch(:svn_location)}", release_path
    end
  end
end
