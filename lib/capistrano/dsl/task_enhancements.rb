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
  end
end
