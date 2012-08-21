require 'capistrano/callback'

module Capistrano
  class Configuration
    module Callbacks
      def self.included(base) #:nodoc:
        %w(initialize invoke_task_directly).each do |method|
          base.send :alias_method, "#{method}_without_callbacks", method
          base.send :alias_method, method, "#{method}_with_callbacks"
        end
      end

      # The hash of callbacks that have been registered for this configuration
      attr_reader :callbacks

      def initialize_with_callbacks(*args) #:nodoc:
        initialize_without_callbacks(*args)
        @callbacks = {}
      end

      def invoke_task_directly_with_callbacks(task) #:nodoc:

        trigger :before, task

        result = invoke_task_directly_without_callbacks(task)

        trigger :after, task

        return result
      end

      # Defines a callback to be invoked before the given task. You must
      # specify the fully-qualified task name, both for the primary task, and
      # for the task(s) to be executed before. Alternatively, you can pass a
      # block to be executed before the given task.
      #
      #   before "deploy:update_code", :record_difference
      #   before :deploy, "custom:log_deploy"
      #   before :deploy, :this, "then:this", "and:then:this"
      #   before :some_task do
      #     puts "an anonymous hook!"
      #   end
      #
      # This just provides a convenient interface to the more general #on method.
      def before(task_name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        args << options.merge(:only => task_name)
        on :before, *args, &block
      end

      # Defines a callback to be invoked after the given task. You must
      # specify the fully-qualified task name, both for the primary task, and
      # for the task(s) to be executed after. Alternatively, you can pass a
      # block to be executed after the given task.
      #
      #   after "deploy:update_code", :log_difference
      #   after :deploy, "custom:announce"
      #   after :deploy, :this, "then:this", "and:then:this"
      #   after :some_task do
      #     puts "an anonymous hook!"
      #   end
      #
      # This just provides a convenient interface to the more general #on method.
      def after(task_name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        args << options.merge(:only => task_name)
        on :after, *args, &block
      end

      # Defines one or more callbacks to be invoked in response to some event.
      # Capistrano currently understands the following events:
      #
      # * :before, triggered before a task is invoked
      # * :after, triggered after a task is invoked
      # * :start, triggered before a top-level task is invoked via the command-line
      # * :finish, triggered when a top-level task completes
      # * :load, triggered after all recipes have loaded
      # * :exit, triggered after all tasks have completed
      #
      # Specify the (fully-qualified) task names that you want invoked in
      # response to the event. Alternatively, you can specify a block to invoke
      # when the event is triggered. You can also pass a hash of options as the
      # last parameter, which may include either of two keys:
      #
      # * :only, should specify an array of task names. Restricts this callback
      #   so that it will only fire when the event applies to those tasks.
      # * :except, should specify an array of task names. Restricts this callback
      #   so that it will never fire when the event applies to those tasks.
      #
      # Usage:
      #
      #  on :before, "some:hook", "another:hook", :only => "deploy:update"
      #  on :after, "some:hook", :except => "deploy:create_symlink"
      #  on :before, "global:hook"
      #  on :after, :only => :deploy do
      #    puts "after deploy here"
      #  end
      def on(event, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        callbacks[event] ||= []

        if args.empty? && block.nil?
          raise ArgumentError, "please specify either a task name or a block to invoke"
        elsif args.any? && block
          raise ArgumentError, "please specify only a task name or a block, but not both"
        elsif block
          callbacks[event] << ProcCallback.new(block, options)
        else
          args = filter_deprecated_tasks(args)
          options[:only] = filter_deprecated_tasks(options[:only])
          options[:except] = filter_deprecated_tasks(options[:except])

          callbacks[event].concat(args.map { |name| TaskCallback.new(self, name, options) })
        end
      end

      # Filters the given task name or names and attempts to replace deprecated tasks with their equivalents.
      def filter_deprecated_tasks(names)
        deprecation_msg = "[Deprecation Warning] This API has changed, please hook `deploy:create_symlink` instead of" \
          " `deploy:symlink`."

        if names == "deploy:symlink"
          warn deprecation_msg
          names = "deploy:create_symlink"
        elsif names.is_a?(Array) && names.include?("deploy:symlink")
          warn deprecation_msg
          names = names.map { |name| name == "deploy:symlink" ? "deploy:create_symlink" : name }
        end

        names
      end

      # Trigger the named event for the named task. All associated callbacks
      # will be fired, in the order they were defined.
      def trigger(event, task=nil)
        pending = Array(callbacks[event]).select { |c| c.applies_to?(task) }
        if pending.any?
          msg = "triggering #{event} callbacks"
          msg << " for `#{task.fully_qualified_name}'" if task
          logger.trace(msg)
          pending.each { |callback| callback.call }
        end
      end

    end
  end
end
