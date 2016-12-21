require "capistrano/scm/plugin"

class Capistrano::SCM::Git < Capistrano::SCM::Plugin
  def set_defaults
    set_if_empty :git_shallow_clone, false
    set_if_empty :git_enable_submodules, false
    set_if_empty :git_wrapper_path, lambda {
      # Try to avoid permissions issues when multiple users deploy the same app
      # by using different file names in the same dir for each deployer and stage.
      suffix = [:application, :stage, :local_user].map { |key| fetch(key).to_s }.join("-").gsub(/\s+/, "-")
      "#{fetch(:tmp_dir)}/git-ssh-#{suffix}.sh"
    }
    set_if_empty :git_environmental_variables, lambda {
      {
        git_askpass: "/bin/echo",
        git_ssh: fetch(:git_wrapper_path)
      }
    }
  end

  def register_hooks
    after "deploy:new_release_path", "git:create_release"
    before "deploy:check", "git:check"
    before "deploy:set_current_revision", "git:set_current_revision"
  end

  def define_tasks
    eval_rakefile File.expand_path("../tasks/git.rake", __FILE__)
  end

  def repo_mirror_exists?
    backend.test " [ -f #{repo_path}/HEAD ] "
  end

  def check_repo_is_reachable
    git :'ls-remote --heads', repo_url
  end

  def clone_repo
    if (depth = fetch(:git_shallow_clone))
      git :clone, "--mirror", "--depth", depth, "--no-single-branch", repo_url, repo_path.to_s
    else
      git :clone, "--mirror", repo_url, repo_path.to_s
    end
  end

  def update_mirror
    # Note: Requires git version 1.9 or greater
    if (depth = fetch(:git_shallow_clone))
      git :fetch, "--depth", depth, "origin", fetch(:branch)
    else
      git :remote, :update, "--prune"
    end
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

  ##
  # Adds configured submodules recursively to release
  # It does so by connecting the bare repo and the work tree using environment variables
  # The reset creates a temporary index, but does not change the working directory
  # The temporary index is removed after everything is done
  def submodules_to_release_path
    temp_index_file_path = release_path.join("INDEX_#{fetch(:release_timestamp)}")
    backend.within "../releases/#{fetch(:release_timestamp)}" do
      backend.with(
        "GIT_DIR" => repo_path.to_s,
        "GIT_WORK_TREE" => release_path.to_s,
        "GIT_INDEX_FILE" => temp_index_file_path.to_s
      ) do
        git :reset, "--mixed", fetch(:branch)
        git :submodule, "update", "--init", "--depth", 1, "--checkout", "--recursive"
        backend.execute :rm, temp_index_file_path.to_s
      end
    end
  end

  def fetch_revision
    backend.capture(:git, "rev-list --max-count=1 #{fetch(:branch)}")
  end

  def git(*args)
    args.unshift :git
    backend.execute(*args)
  end
end
