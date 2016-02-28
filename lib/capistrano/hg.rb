load File.expand_path("../tasks/hg.rake", __FILE__)

require "capistrano/scm"

class Capistrano::Hg < Capistrano::SCM
  # execute hg in context with arguments
  def hg(*args)
    args.unshift(:hg)
    context.execute(*args)
  end

  module DefaultStrategy
    def test
      test! " [ -d #{repo_path}/.hg ] "
    end

    def check
      hg "id", repo_url
    end

    def clone
      hg "clone", "--noupdate", repo_url, repo_path
    end

    def update
      hg "pull"
    end

    def release
      if (tree = fetch(:repo_tree))
        tree = tree.slice %r#^/?(.*?)/?$#, 1
        components = tree.split("/").size
        hg "archive --type tgz -p . -I", tree, "--rev", fetch(:branch), "| tar -x --strip-components #{components} -f - -C", release_path
      else
        hg "archive", release_path, "--rev", fetch(:branch)
      end
    end

    def fetch_revision
      context.capture(:hg, "log --rev #{fetch(:branch)} --template \"{node}\n\"")
    end
  end
end
