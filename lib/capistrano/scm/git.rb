require "capistrano/scm/plugin"
require "cgi"
require "securerandom"
require "shellwords"
require "stringio"
require "uri"

class Capistrano::SCM::Git < Capistrano::SCM::Plugin
  def set_defaults
    set_if_empty :git_shallow_clone, false
    set_if_empty :git_wrapper_path, lambda {
      # Use a unique name that won't collide with other deployments, and
      # that cannot be guessed by other processes that have access to /tmp.
      "#{fetch(:tmp_dir)}/git-ssh-#{SecureRandom.hex(10)}.sh"
    }
    set_if_empty :git_environmental_variables, lambda {
      {
        git_askpass: "/bin/echo",
        git_ssh: fetch(:git_wrapper_path)
      }
    }
    set_if_empty :git_max_concurrent_connections, 10
    set_if_empty :git_wait_interval, 0
  end

  def register_hooks
    after "deploy:new_release_path", "git:create_release"
    before "deploy:check", "git:check"
    before "deploy:set_current_revision", "git:set_current_revision"
    before "deploy:set_current_revision_time", "git:set_current_revision_time"
  end

  def define_tasks
    eval_rakefile File.expand_path("../tasks/git.rake", __FILE__)
  end

  def repo_mirror_exists?
    backend.test " [ -f #{repo_path}/HEAD ] "
  end

  def check_repo_is_reachable
    git :'ls-remote', git_repo_url, "HEAD"
  end

  def clone_repo
    if (depth = fetch(:git_shallow_clone))
      git :clone, "--mirror", "--depth", depth, "--no-single-branch", git_repo_url, repo_path.to_s
    else
      git :clone, "--mirror", git_repo_url, repo_path.to_s
    end
  end

  def update_mirror
    # Update the origin URL if necessary.
    git :remote, "set-url", "origin", git_repo_url

    # Note: Requires git version 1.9 or greater
    if (depth = fetch(:git_shallow_clone))
      git :fetch, "--depth", depth, "origin", fetch(:branch)
    else
      git :remote, :update, "--prune"
    end
  end

  def verify_commit
    git :"verify-commit", fetch_revision
  end

  def archive_to_release_path
    if (tree = fetch(:repo_tree))
      tree = tree.slice %r#^/?(.*?)/?$#, 1
      components = tree.split("/").size
      git :archive, fetch(:branch), tree, "| #{SSHKit.config.command_map[:tar]} -x --strip-components #{components} -f - -C", release_path
    else
      git :archive, fetch(:branch), "| #{SSHKit.config.command_map[:tar]} -x -f - -C", release_path
    end
  end

  def fetch_revision
    backend.capture(:git, "rev-list --max-count=1 #{fetch(:branch)}")
  end

  def fetch_revision_time
    backend.capture(:git, "--no-pager log -1 --pretty=format:\"%ct\" #{fetch(:branch)}")
  end

  def git(*args)
    args.unshift :git
    backend.execute(*args)
  end

  def git_repo_url
    if fetch(:git_http_username) && fetch(:git_http_password)
      URI.parse(repo_url).tap do |repo_uri|
        repo_uri.user     = fetch(:git_http_username)
        repo_uri.password = CGI.escape(fetch(:git_http_password))
      end.to_s
    elsif fetch(:git_http_username)
      URI.parse(repo_url).tap do |repo_uri|
        repo_uri.user = fetch(:git_http_username)
      end.to_s
    else
      repo_url
    end
  end
end
