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
      test! :svn, :info, repo_url, authentication
    end

    def clone
      svn :checkout, repo_url, repo_path, authentication
    end

    def update
      svn :update, authentication
    end

    def release
      svn :export, '.', release_path, authentication
    end

    def fetch_revision
      context.capture(:svn, "log -r HEAD -q | tail -n 2 | head -n 1 | sed s/\ \|.*/''/")
    end

    private

      def authentication
        username = fetch(:svn_username)
        password = fetch(:svn_password)
        return "" unless username && password
        result = %(--username "#{username}" )
        result << %(--password "#{password}" )
        result << "--no-auth-cache "
        result.strip
      end
  end
end
