load File.expand_path("../tasks/svn.rake", __FILE__)

require 'capistrano/scm'

class Capistrano::Svn < Capistrano::SCM

  # execute svn with argument in the context
  #
  def svn(*args)
    args.unshift(:svn)
    context.execute *args
  end

  module DefaultStrategy
    def test
      return true
    end

    def check
      test! :svn, :info, repo_url
    end

    def clone
      return true
    end

    def update
      return true
    end

    def release
      svn :export, "#{repo_url}/#{fetch(:svn_location)}", release_path
    end
  end
end