load File.expand_path("../tasks/git.rake", __FILE__)

module Capistrano::Git
  class << self
    def test(context)
      context.test " [ -f #{context.repo_path}/HEAD ] "
    end

    def check(context)
      exit 1 unless context.test :git, :'ls-remote', context.repo_url
    end

    def clone(context)
      context.execute :git, :clone, '--mirror', context.repo_url, context.repo_path
    end

    def update(context)
      context.execute :git, :remote, :update
    end

    def release(context)
      context.execute :git, :archive, context.fetch(:branch), '| tar -x -C', context.release_path
    end
  end
end
