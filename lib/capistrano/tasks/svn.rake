namespace :svn do
  def strategy
    @strategy ||= Capistrano::Svn.new(self, fetch(:svn_strategy, Capistrano::Svn::DefaultStrategy))
  end

  desc 'Check that the repo is reachable'
  task :check do
    on release_roles :all do
      strategy.check
    end
  end

  desc 'Copy repo to releases'
  task :create_release do
    Capistrano::Configuration.ask(:svn_location, "trunk")
    on release_roles :all do
      strategy.release
    end
  end
end
