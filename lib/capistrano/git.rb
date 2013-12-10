load File.expand_path("../tasks/git.rake", __FILE__)

require 'capistrano/scm'

class Capistrano::Git < Capistrano::SCM

  # execute git with argument in the context
  #
  def git(*args)
    args.unshift :git
    context.execute *args
  end

  # The Capistrano default strategy for git. You should want to use this.
  module DefaultStrategy
    def test
      test! " [ -f #{repo_path}/HEAD ] "
    end

    def check
      test! :git, :'ls-remote', repo_url
    end

    def clone
      git :clone, '--mirror', repo_url, repo_path
    end

    def update
      git :remote, :update
    end

    def release
      git :archive, fetch(:branch), '| tar -x -C', release_path
    end
  end
end
