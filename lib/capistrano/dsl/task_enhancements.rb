require 'capistrano/upload_task'

module Capistrano
  module TaskEnhancements
    def before(task, prerequisite, *args, &block)
      scoped_prereq = \
        if block_given?
          Rake::Task.define_task(prerequisite, *args, &block)
        else
          # If we are inside a `namespace` block, make sure the to include that
          # implied scope in the name of the task.
          Rake.application.current_scope.path_with_task_name(prerequisite)
        end

      # The rake: prefix forces Rake to resolve the prerequisite exactly as
      # we declared it, rather than using the namespace of the enhanced task.
      Rake::Task[task].enhance ["rake:#{scoped_prereq}"]
    end

    def after(task, post_task, *args, &block)
      Rake::Task.define_task(post_task, *args, &block) if block_given?
      task = Rake::Task[task]

      # If we are in a `namespace` block, hold onto that implied scope and reuse
      # it during invocation of the enhancement to ensure the correct behavior.
      namespace = Rake.application.current_scope

      task.enhance do
        Rake.application.lookup(post_task, namespace).invoke
      end
    end

    def remote_file(task)
      target_roles = task.delete(:roles) { :all }
      define_remote_file_task(task, target_roles)
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
      invoke 'deploy:failed'
      exit(false)
    end

    def deploying?
      fetch(:deploying, false)
    end

  end
end
