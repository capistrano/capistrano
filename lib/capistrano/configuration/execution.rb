require 'capistrano/errors'

module Capistrano
  class Configuration
    module Execution
      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_execution, :initialize
        base.send :alias_method, :initialize, :initialize_with_execution
      end

      # A struct for representing a single instance of an invoked task.
      TaskCallFrame = Struct.new(:task, :rollback)

      def initialize_with_execution(*args) #:nodoc:
        initialize_without_execution(*args)
      end
      private :initialize_with_execution

      # Returns true if there is a transaction currently active.
      def transaction?
        !rollback_requests.nil?
      end

      # The call stack of the tasks. The currently executing task may inspect
      # this to see who its caller was. The current task is always the last
      # element of this stack.
      def task_call_frames
        Thread.current[:task_call_frames] ||= []
      end

      # The Array of task continuations currently on the call stack, whose primary purpose is to inform {#execute_task}
      # on not applying the same task continuation twice.
      def task_continuations
        Thread.current[:task_continuations] ||= []
      end

      # The stack of tasks that have registered rollback handlers within the
      # current transaction. If this is nil, then there is no transaction
      # that is currently active.
      def rollback_requests
        Thread.current[:rollback_requests]
      end

      def rollback_requests=(rollback_requests)
        Thread.current[:rollback_requests] = rollback_requests
      end

      # Invoke a set of tasks in a transaction. If any task fails (raises an
      # exception), all tasks executed within the transaction are inspected to
      # see if they have an associated on_rollback hook, and if so, that hook
      # is called.
      def transaction
        raise ArgumentError, "expected a block" unless block_given?
        raise ScriptError, "transaction must be called from within a task" if task_call_frames.empty?

        return yield if transaction?

        logger.info "transaction: start"
        begin
          self.rollback_requests = []
          yield
          logger.info "transaction: commit"
        rescue Object => e
          rollback!
          raise
        ensure
          self.rollback_requests = nil
        end
      end

      # Specifies an on_rollback hook for the currently executing task. If this
      # or any subsequent task then fails, and a transaction is active, this
      # hook will be executed.
      def on_rollback(&block)
        if transaction?
          # don't note a new rollback request if one has already been set
          rollback_requests << task_call_frames.last unless task_call_frames.last.rollback
          task_call_frames.last.rollback = block
        end
      end

      # Returns the TaskDefinition object for the currently executing task.
      # It returns nil if there is no task being executed.
      def current_task
        return nil if task_call_frames.empty?
        task_call_frames.last.task
      end

      # Executes the task or task continuation with the given name, without invoking any associated callbacks.
      def execute_task(task, &block)
        if !task.continuation? || !task_continuations.include?(task)
          begin
            logger.debug "executing the task #{task.continuation? ? "continuation " : ""}`#{task.fully_qualified_name}'"
            push_task_call_frame(task)
            invoke_task_directly(task, &block)
          ensure
            pop_task_call_frame
          end
        else
          block.call
        end
      end

      # Attempts execute the task and task continuations at the given fully-qualified path. If no such task or task
      # continuations exist, a Capistrano::NoSuchTaskError will be raised.
      def find_and_execute_task(path, hooks={})
        explicit_paths = path.split("::", -1)
        explicit_paths = [""] if explicit_paths.empty?

        task_continuations = explicit_paths[0...-1].map do |path|
          parts = path.split(":", -1)
          current_ns = self
          current_parts = []
          task = nil

          while !parts.empty?
            next_part = parts.shift.to_sym
            current_parts.push(next_part)

            if current_ns.namespaces.key?(next_part)
              current_ns = current_ns.namespaces[next_part]
            elsif current_ns.tasks.key?(next_part)
              task = current_ns.tasks[next_part]

              if task.continuation?
                raise ArgumentError, "the task continuation `#{current_parts.join(":")}' cannot have redundant name" \
                  " components `#{parts.join(":")}'" \
                  if !parts.empty?
              else
                raise ArgumentError, "expected the task continuation `#{current_parts.join(":")}', not a normal task"
              end
            else
              raise NoSuchTaskError, "the task continuation `#{current_parts.join(":")}' does not exist"
            end
          end

          raise NoSuchTaskError, "the task continuation `#{current_parts.join(":")}' does not exist" if task.nil?

          task
        end

        parts = explicit_paths[-1].split(":", -1)
        current_ns = self
        current_parts = []
        task = nil

        while !parts.empty?
          next_part = parts.shift.to_sym
          current_parts.push(next_part)

          if current_ns.namespaces.key?(next_part)
            current_ns = current_ns.namespaces[next_part]
          elsif current_ns.tasks.key?(next_part)
            task = current_ns.tasks[next_part]

            if !task.continuation?
              raise ArgumentError, "the task `#{current_parts.join(":")}' cannot have redundant name components" \
                " `#{parts.join(":")}'" \
                if !parts.empty?
            else
              task_continuations.push(task)
              task = nil
            end
          else
            raise NoSuchTaskError, "the task `#{current_parts.join(":")}' does not exist"
          end
        end

        task = current_ns.tasks[Capistrano::Configuration::Namespaces::DEFAULT_TASK] if task.nil?

        raise NoSuchTaskError, "the task `#{current_parts.join(":")}' does not exist" if task.nil?

        # Build an aggregate continuation representing the execution of all the applied task continuations.

        current_continuation = Proc.new { |&block| block.call }

        task_continuations.each do |task_continuation|
          current_continuation = Execution.add_continuation(current_continuation) do |&block|
            trigger(hooks[:before], task_continuation) if !hooks[:before].nil?
            result = execute_task(task_continuation, &block)
            trigger(hooks[:after], task_continuation) if !hooks[:after].nil?
            result
          end
        end

        # Execute the task within the aggregate continuation.
        current_continuation.call do
          trigger(hooks[:before], task) if !hooks[:before].nil?
          result = execute_task(task)
          trigger(hooks[:after], task) if !hooks[:after].nil?
          result
        end
      end

      # Wraps the given continuation with the current continuation.
      def self.add_continuation(current_continuation, &continuation)
        # The new continuation.
        Proc.new do |&block|
          # Invoke the current continuation with a Proc wrapping an invocation of the old continuation as its argument.
          current_continuation.call do
            continuation.call(&block)
          end
        end
      end

    protected

      def rollback!
        return if Thread.current[:rollback_requests].nil?

        # throw the task back on the stack so that roles are properly
        # interpreted in the scope of the task in question.
        rollback_requests.reverse.each do |frame|
          begin
            push_task_call_frame(frame.task)
            logger.important "rolling back", frame.task.fully_qualified_name
            frame.rollback.call
          rescue Object => e
            logger.info "exception while rolling back: #{e.class}, #{e.message}", frame.task.fully_qualified_name
          ensure
            pop_task_call_frame
          end
        end
      end

      def push_task_call_frame(task)
        task_continuations.push(task) if task.continuation?

        frame = TaskCallFrame.new(task)
        task_call_frames.push frame
      end

      def pop_task_call_frame
        frame = task_call_frames.pop

        task_continuations.pop if frame.task.continuation?
      end

      # Invokes the task or task continuation's body directly, without setting up the call frame.
      def invoke_task_directly(task, &block)
        task.namespace.send("_execute_#{task.name}".to_sym, &block)
      end
    end
  end
end
