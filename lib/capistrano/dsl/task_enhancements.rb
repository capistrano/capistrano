module Capistrano
  module TaskEnhancements
    def before(task, prerequisite, *args, &block)
      prerequisite = Rake::Task.define_task(prerequisite, *args, &block) if block_given?
      Rake::Task[task].enhance [prerequisite]
    end

    def after(task, post_task, *args, &block)
      post_task = Rake::Task.define_task(post_task, *args, &block) if block_given?
      Rake::Task[task].enhance do
        invoke(post_task)
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

  end
end
