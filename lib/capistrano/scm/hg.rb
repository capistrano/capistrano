require "capistrano/scm/plugin"
require "securerandom"

class Capistrano::SCM::Hg < Capistrano::SCM::Plugin
  def register_hooks
    after "deploy:new_release_path", "hg:create_release"
    before "deploy:check", "hg:check"
    before "deploy:set_current_revision", "hg:set_current_revision"
  end

  def define_tasks
    eval_rakefile File.expand_path("../tasks/hg.rake", __FILE__)
  end

  def hg(*args)
    args.unshift(:hg)
    backend.execute(*args)
  end

  def repo_mirror_exists?
    backend.test " [ -d #{repo_path}/.hg ] "
  end

  def check_repo_is_reachable
    hg "id", repo_url
  end

  def clone_repo
    hg "clone", "--noupdate", repo_url, repo_path.to_s
  end

  def update_mirror
    hg "pull"
  end

  def archive_to_release_path
    if (tree = fetch(:repo_tree))
      tree = tree.slice %r#^/?(.*?)/?$#, 1
      components = tree.split("/").size
      temp_tar = "#{fetch(:tmp_dir)}/#{SecureRandom.hex(10)}.tar"

      hg "archive -p . -I", tree, "--rev", fetch(:branch), temp_tar

      backend.execute :mkdir, "-p", release_path
      backend.execute :tar, "-x --strip-components #{components} -f", temp_tar, "-C", release_path
      backend.execute :rm, temp_tar
    else
      hg "archive", release_path, "--rev", fetch(:branch)
    end
  end

  def fetch_revision
    backend.capture(:hg, "log --rev #{fetch(:branch)} --template \"{node}\n\"")
  end
end
