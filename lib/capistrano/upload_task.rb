require "rake/file_creation_task"

module Capistrano
  class UploadTask < Rake::FileCreationTask
    def needed?
      true # always needed because we can't check remote hosts
    end
  end
end
