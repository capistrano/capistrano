module Capistrano
  module TaskEnhancements
    def before(task, prerequisite, *args, &block)
      if block_given?
        prerequisite_task = Rake::Task.define_task(prerequisite, *args, &block)
      else
        prerequisite_task = Rake::Task.define_task("before_#{task}_run_#{prerequisite}") do
          Rake::Task[prerequisite].invoke(*args)
        end
      end
      Rake::Task[task].enhance [prerequisite_task]
    end

    def after(task, post_task, *formal_args, &block)
      Rake::Task.define_task(post_task, *formal_args, &block) if block_given?
      post_task = Rake::Task[post_task]
      Rake::Task[task].enhance do |t, real_args|
        if block_given?
          post_task.invoke(*real_args)
        else
          post_task.invoke(*formal_args)
        end
      end
    end

    def remote_file(task)
      target_roles = task.delete(:roles) { :all }
      define_remote_file_task(task, target_roles)
    end

    def define_remote_file_task(task, target_roles)
      Rake::Task.define_task(task) do |t|
        prerequisite_file = t.prerequisites.first
        file = shared_path.join(t.name)

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
