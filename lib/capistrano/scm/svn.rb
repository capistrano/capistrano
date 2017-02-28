require "capistrano/scm/plugin"

class Capistrano::SCM::Svn < Capistrano::SCM::Plugin
  def register_hooks
    after "deploy:new_release_path", "svn:create_release"
    before "deploy:check", "svn:check"
    before "deploy:set_current_revision", "svn:set_current_revision"
  end

  def define_tasks
    eval_rakefile File.expand_path("../tasks/svn.rake", __FILE__)
  end

  def svn(*args)
    args.unshift(:svn)
    args.push "--username #{fetch(:svn_username)}" if fetch(:svn_username)
    args.push "--password #{fetch(:svn_password)}" if fetch(:svn_password)
    args.push "--revision #{fetch(:svn_revision)}" if fetch(:svn_revision)
    backend.execute(*args)
  end

  def repo_mirror_exists?
    backend.test " [ -d #{repo_path}/.svn ] "
  end

  def check_repo_is_reachable
    svn_username = fetch(:svn_username) ? "--username #{fetch(:svn_username)}" : ""
    svn_password = fetch(:svn_password) ? "--password #{fetch(:svn_password)}" : ""
    backend.test :svn, :info, repo_url, svn_username, svn_password
  end

  def clone_repo
    svn :checkout, repo_url, repo_path.to_s
  end

  def update_mirror
    # Switch the repository URL if necessary.
    repo_mirror_url = fetch_repo_mirror_url
    svn :switch, repo_url unless repo_mirror_url == repo_url
    svn :update
  end

  def archive_to_release_path
    svn :export, "--force", ".", release_path
  end

  def fetch_revision
    backend.capture(:svnversion, repo_path.to_s)
  end

  def fetch_repo_mirror_url
    backend.capture(:svn, :info, repo_path.to_s).each_line do |line|
      return $1 if /\AURL: (.*)\n\z/ =~ line
    end
  end
end
