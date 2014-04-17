load File.expand_path("../tasks/svn.rake", __FILE__)

require 'capistrano/scm'

class Capistrano::Svn < Capistrano::SCM
  
  # execute svn in context with arguments
  def svn(*args)
    args.unshift(:svn)
    context.execute *args
  end

  module DefaultStrategy
    def test
      test! " [ -d #{repo_path}/.svn ] "
    end

    def check
      test! :svn, :info, repo_url
    end

    def clone
      svn :checkout, repo_url, repo_path
    end

    def update
      svn :update
    end

    def release
      svn :export, '--force', '.', release_path
    end

    def fetch_revision
      context.capture(:svnversion, repo_path)
    end
  end
end
