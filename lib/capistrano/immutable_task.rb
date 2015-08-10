module Capistrano
  # This module extends a Rake::Task to freeze it to prevent it from being
  # enhanced. This is used to prevent users from enhancing a task at the wrong
  # point of Capistrano's boot process, which can happen if a Capistrano plugin
  # is loaded in deploy.rb by mistake (instead of in the Capfile).
  #
  # Usage:
  #
  # task = Rake.application["load:defaults"]
  # task.invoke
  # task.extend(Capistrano::ImmutableTask) # prevent further modifications
  #
  module ImmutableTask
    def self.extended(task)
      task.freeze
    end

    def enhance(*args, &block)
      $stderr.puts <<-MESSAGE
WARNING: #{name} has already been invoked and can no longer be modified.
Check that you haven't loaded a Capistrano plugin in deploy.rb by mistake.
Plugins must be loaded in the Capfile to initialize properly.
MESSAGE

      # This will raise a frozen object error
      super(*args, &block)
    end
  end
end
