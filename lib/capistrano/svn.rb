load File.expand_path("../tasks/svn.rake", __FILE__)

require "capistrano/scm"

class Capistrano::Svn < Capistrano::SCM
  # execute svn in context with arguments
  def svn(*args)
    args.unshift(:svn)
    args.push "--username #{fetch(:svn_username)}" if fetch(:svn_username)
    args.push "--password #{fetch(:svn_password)}" if fetch(:svn_password)
    args.push "--revision #{fetch(:svn_revision)}" if fetch(:svn_revision)
    context.execute(*args)
  end

  module DefaultStrategy
    def test
      test! " [ -d #{repo_path}/.svn ] "
    end

    def check
      svn_username = fetch(:svn_username) ? "--username #{fetch(:svn_username)}" : ""
      svn_password = fetch(:svn_password) ? "--password #{fetch(:svn_password)}" : ""
      test! :svn, :info, repo_url, svn_username, svn_password
    end

    def clone
      svn :checkout, repo_url, repo_path
    end

    def update
      svn :update
    end

    def release
      svn :export, "--force", ".", release_path
    end

    def fetch_revision
      context.capture(:svnversion, repo_path)
    end
  end
end
