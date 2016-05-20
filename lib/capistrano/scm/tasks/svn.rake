# TODO: this is nearly identical to git.rake. DRY up?

# This trick lets us access the Svn plugin within `on` blocks.
svn = self

namespace :svn do
  desc "Check that the repo is reachable"
  task :check do
    on release_roles :all do
      svn.check_repo_is_reachable
    end
  end

  desc "Clone the repo to the cache"
  task :clone do
    on release_roles :all do
      if svn.repo_mirror_exists?
        info t(:mirror_exists, at: repo_path)
      else
        within deploy_path do
          svn.clone_repo
        end
      end
    end
  end

  desc "Pull changes from the remote repo"
  task update: :'svn:clone' do
    on release_roles :all do
      within repo_path do
        svn.update_mirror
      end
    end
  end

  desc "Copy repo to releases"
  task create_release: :'svn:update' do
    on release_roles :all do
      within repo_path do
        svn.archive_to_release_path
      end
    end
  end

  desc "Determine the revision that will be deployed"
  task :set_current_revision do
    on release_roles :all do
      within repo_path do
        set :current_revision, svn.fetch_revision
      end
    end
  end
end
