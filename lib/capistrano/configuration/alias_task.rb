module Capistrano
  class Configuration
    module AliasTask
      # Attempts to find the task at the given fully-qualified path, and
      # alias it. If arguments don't have correct task names, an ArgumentError
      # wil be raised. If no such task exists, a Capistrano::NoSuchTaskError
      # will be raised.
      #
      # Usage:
      #
      #   alias_task :original_deploy, :deploy
      #
      def alias_task(new_name, old_name)
        if !new_name.respond_to?(:to_sym) or !old_name.respond_to?(:to_sym)
          raise ArgumentError, "expected a valid task name"
        end

        original_task = find_task(old_name) or raise NoSuchTaskError, "the task `#{old_name}' does not exist"
        task = original_task.dup # Dup. task to avoid modify original task
        task.name = new_name

        define_task(task)
      end
    end
  end
end
