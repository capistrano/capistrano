# This trick lets us access the Git plugin within `on` blocks.
git_plugin = self

namespace :git do
  desc "Upload the git wrapper script, this script guarantees that we can script git without getting an interactive prompt"
  task :wrapper do
    on release_roles(:all), in: :groups, limit: fetch(:git_max_concurrent_connections), wait: fetch(:git_wait_interval) do
      execute :mkdir, "-p", File.dirname(fetch(:git_wrapper_path)).shellescape
      upload! StringIO.new("#!/bin/sh -e\nexec /usr/bin/env ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no \"$@\"\n"), fetch(:git_wrapper_path)
      execute :chmod, "700", fetch(:git_wrapper_path).shellescape
    end
  end

  desc "Check that the repository is reachable"
  task check: :'git:wrapper' do
    fetch(:branch)
    on release_roles(:all), in: :groups, limit: fetch(:git_max_concurrent_connections), wait: fetch(:git_wait_interval) do
      with fetch(:git_environmental_variables) do
        git_plugin.check_repo_is_reachable
      end
    end
  end

  desc "Clone the repo to the cache"
  task clone: :'git:wrapper' do
    on release_roles(:all), in: :groups, limit: fetch(:git_max_concurrent_connections), wait: fetch(:git_wait_interval) do
      if git_plugin.repo_mirror_exists?
        info t(:mirror_exists, at: repo_path)
      else
        within deploy_path do
          with fetch(:git_environmental_variables) do
            git_plugin.clone_repo
          end
        end
      end
    end
  end

  desc "Update the repo mirror to reflect the origin state"
  task update: :'git:clone' do
    on release_roles(:all), in: :groups, limit: fetch(:git_max_concurrent_connections), wait: fetch(:git_wait_interval) do
      within repo_path do
        with fetch(:git_environmental_variables) do
          git_plugin.update_mirror
        end
      end
    end
  end

  desc "Copy repo to releases"
  task create_release: :'git:update' do
    on release_roles(:all), in: :groups, limit: fetch(:git_max_concurrent_connections), wait: fetch(:git_wait_interval) do
      with fetch(:git_environmental_variables) do
        within repo_path do
          execute :mkdir, "-p", release_path
          git_plugin.archive_to_release_path
        end
      end
    end
  end

  desc "Determine the revision that will be deployed"
  task :set_current_revision do
    on release_roles(:all), in: :groups, limit: fetch(:git_max_concurrent_connections), wait: fetch(:git_wait_interval) do
      within repo_path do
        with fetch(:git_environmental_variables) do
          set :current_revision, git_plugin.fetch_revision
        end
      end
    end
  end
end
