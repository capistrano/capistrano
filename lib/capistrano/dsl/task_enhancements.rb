require 'tmpdir'
require 'pathname'

module Capistrano
  module TaskEnhancements
    def before(task, prerequisite, *args, &block)
      prerequisite = Rake::Task.define_task(prerequisite, *args, &block) if block_given?
      Rake::Task[task].enhance [prerequisite]
    end

    def after(task, post_task, *args, &block)
      Rake::Task.define_task(post_task, *args, &block) if block_given?
      post_task = Rake::Task[post_task]
      Rake::Task[task].enhance do
        post_task.invoke
      end
    end

    def remote_file(task)
      target_roles = task.delete(:roles) { :all }
      define_remote_file_task(task, target_roles)
    end

    def define_remote_file_task(task, target_roles)
      Rake::Task.define_task(task) do |t|
        prerequisite_file = t.prerequisites.first

        # Extract the task name; ignore any
        # scope a user may have accidentally
        # attached that could be in `t.name`
        task_name = task.keys.first
        if Pathname.new(task_name).absolute?
          file = task_name
        else
          file = File.join((fetch(:shared_path) || Dir.tmpdir), task_name)
        end

        on roles(target_roles) do
          unless test "[ -f #{file} ]"
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
      warn t(:deploy_failed, ex: ex.inspect)
      invoke 'deploy:failed'
      exit(false)
    end

    def deploying?
      fetch(:deploying, false)
    end

  end
end
