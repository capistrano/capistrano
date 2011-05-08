module Capistrano
  class Configuration
    module AliasTask
      # Attempts to find the task at the given fully-qualified path, and
      # alias it. If arguments don't have correct task names, an ArgumentError
      # wil be raised. If no such task exists, a Capistrano::NoSuchTaskError
      # will be raised.
      def alias_task(new_name, old_name)
        if !new_name.respond_to?(:to_sym) or !old_name.respond_to?(:to_sym)
          raise ArgumentError, "expected a valid task name"
        end

        task = find_task(old_name) or raise NoSuchTaskError, "the task `#{old_name}' does not exist"

        options = {}
        options[:desc] = task.description
        options[:on_error] = task.on_error
        options[:max_hosts] = task.max_hosts

        task(new_name, options, &task.body)
      end
    end
  end
end
