load File.expand_path("../tasks/hg.rake", __FILE__)

module Capistrano::Hg
  class << self
    def test(context)
      context.test " [ -d #{context.repo_path}/.hg ] "
    end

    def check(context)
      context.execute "hg", "id", context.repo_url
    end

    def clone(context)
      context.execute "hg", "clone", "--noupdate", context.repo_url, context.repo_path
    end

    def update(context)
      context.execute "hg", "pull"
    end

    def release(context)
      context.execute "hg", "archive", context.release_path, "--rev", context.fetch(:branch)
    end
  end
end
