require "capistrano/upload_task"

module Capistrano
  module TaskEnhancements
    def before(task, prerequisite, *args, &block)
      prerequisite = Rake::Task.define_task(prerequisite, *args, &block) if block_given?
      Rake::Task[task].enhance [prerequisite]
    end

    def after(task, post_task, *args, &block)
      Rake::Task.define_task(post_task, *args, &block) if block_given?
      task = Rake::Task[task]
      task.enhance do
        post = Rake.application.lookup(post_task, task.scope)
        raise ArgumentError, "Task #{post_task.inspect} not found" unless post
        post.invoke
      end
    end

    def define_remote_file_task(task, target_roles)
      Capistrano::UploadTask.define_task(task) do |t|
        prerequisite_file = t.prerequisites.first
        file = shared_path.join(t.name)

        on roles(target_roles) do
          unless test "[ -f #{file.to_s.shellescape} ]"
            info "Uploading #{prerequisite_file} to #{file}"
            upload! File.open(prerequisite_file), file
          end
        end
      end
    end

    def ensure_stage
      Rake::Task.define_task(:ensure_stage) do
        unless stage_set?
          puts t(:stage_not_set)
          exit 1
        end
      end
    end

    def tasks_without_stage_dependency
      stages + default_tasks
    end

    def default_tasks
      %w{install}
    end

    def exit_deploy_because_of_exception(ex)
      warn t(:deploy_failed, ex: ex.message)
      invoke "deploy:failed"
      exit(false)
    end

    def deploying?
      fetch(:deploying, false)
    end
  end
end
