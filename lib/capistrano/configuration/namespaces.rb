require 'capistrano/task_definition'

module Capistrano
  class Configuration
    module Namespaces
      DEFAULT_TASK = :default

      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_namespaces, :initialize
        base.send :alias_method, :initialize, :initialize_with_namespaces
      end

      # The name of this namespace. Defaults to +nil+ for the top-level
      # namespace.
      attr_reader :name

      # The parent namespace of this namespace. Returns +nil+ for the top-level
      # namespace.
      attr_reader :parent

      # The hash of tasks defined for this namespace.
      attr_reader :tasks

      # The hash of namespaces defined for this namespace.
      attr_reader :namespaces

      def initialize_with_namespaces(*args) #:nodoc:
        @name = @parent = nil
        initialize_without_namespaces(*args)
        @tasks = {}
        @namespaces = {}
      end
      private :initialize_with_namespaces

      # Returns the top-level namespace (the one with no parent).
      def top
        return parent.top if parent
        return self
      end

      # Returns the fully-qualified name of this namespace, or nil if the
      # namespace is at the top-level.
      def fully_qualified_name
        return nil if name.nil?
        [parent.fully_qualified_name, name].compact.join(":")
      end

      # Describe the next task to be defined. The given text will be attached to
      # the next task that is defined and used as its description.
      def desc(text)
        @next_description = text
      end

      # Returns the value set by the last, pending "desc" call. If +reset+ is
      # not false, the value will be reset immediately afterwards.
      def next_description(reset=false)
        @next_description
      ensure
        @next_description = nil if reset
      end

      # Open a namespace in which to define new tasks. If the namespace was
      # defined previously, it will be reopened, otherwise a new namespace
      # will be created for the given name.
      def namespace(name, &block)
        name = name.to_sym
        raise ArgumentError, "expected a block" unless block_given?

        ensure_not_shadowing(:namespace, name)

        namespaces[name] ||= Namespace.new(name, self)
        namespaces[name].instance_eval(&block)

        # make sure any open description gets terminated
        namespaces[name].desc(nil)

        metaclass = class << self; self; end
        metaclass.send(:define_method, name) { NamespaceContext.new(namespaces[name]) }
      end

      # Describe a new task. If a description is active (see #desc), it is added
      # to the options under the <tt>:desc</tt> key. The new task is added to
      # the namespace.
      def task(name, options={}, &block)
        name = name.to_sym
        raise ArgumentError, "expected a block" unless block_given?

        ensure_not_shadowing(:task, name)

        task = TaskDefinition.new(name, self, {:desc => next_description(:reset)}.merge(options), &block)

        define_task(task)
      end

      def define_task(task)
        tasks[task.name] = task

        if !task.continuation?
          execute_task_body = Proc.new { execute_task(task) }
        else
          execute_task_body = Proc.new do
            ns_context = NamespaceContext.new(self)
            ns_context.task_continuations.push(task)
            ns_context
          end
        end

        metaclass = class << self
          self
        end

        metaclass.send(:define_method, task.name, &execute_task_body)
        metaclass.send(:define_method, "_execute_#{task.name}".to_s, &task.body)
      end

      # Find the task with the given name, where name is the fully-qualified
      # name of the task. This will search into the namespaces and return
      # the referenced task, or nil if no such task can be found. If the name
      # refers to a namespace, the task in that namespace named "default"
      # will be returned instead, if one exists.
      def find_task(name)
        parts = name.to_s.split(/:/)
        tail = parts.pop.to_sym

        ns = self
        until parts.empty?
          next_part = parts.shift
          ns = next_part.empty? ? nil : ns.namespaces[next_part.to_sym]
          return nil if ns.nil?
        end

        if ns.namespaces.key?(tail)
          ns = ns.namespaces[tail]
          tail = DEFAULT_TASK
        end

        ns.tasks[tail]
      end

      # Given a task name, this will search the current namespace, and all
      # parent namespaces, looking for a task that matches the name, exactly.
      # It returns the task, if found, or nil, if not.
      def search_task(name)
        name = name.to_sym
        ns = self

        until ns.nil?
          return ns.tasks[name] if ns.tasks.key?(name)
          ns = ns.parent
        end

        return nil
      end

      # Returns the default task for this namespace. This will be +nil+ if
      # the namespace is at the top-level, and will otherwise return the
      # task named "default". If no such task exists, +nil+ will be returned.
      def default_task
        return nil if parent.nil?
        return tasks[DEFAULT_TASK]
      end

      # Returns the tasks in this namespace as an array of TaskDefinition
      # objects. If a non-false parameter is given, all tasks in all
      # namespaces under this namespace will be returned as well.
      def task_list(all=false)
        list = tasks.values
        namespaces.each { |name,space| list.concat(space.task_list(:all)) } if all
        list
      end

      private

        def all_methods
          public_methods.concat(protected_methods).concat(private_methods)
        end

        # Ensures that the given entity type and name do not shadow an existing entity.
        def ensure_not_shadowing(type, name)
          case type
            when :namespace
              defined = namespaces.key?(name)
            when :task
              defined = tasks.key?(name)
            else
              raise ArgumentError, "the name `#{name}' could not be resolved to an entity"
          end

          if all_methods.any? { |m| m.to_sym == name } && !defined
            if namespaces.key?(name)
              other_type = :namespace
            elsif tasks.key?(name)
              other_type = :task
            else
              raise ArgumentError, "the name `#{name}' could not be resolved to an entity"
            end

            raise ArgumentError, "defining the #{type} `#{name}' would shadow an existing #{other_type} with that name"
          end

          defined
        end

        class Namespace
          def initialize(name, parent)
            @parent = parent
            @name = name
          end

          def role(*args)
            raise NotImplementedError, "roles cannot be defined in a namespace"
          end

          def respond_to?(sym, include_priv=false)
            super || parent.respond_to?(sym, include_priv)
          end

          def method_missing(sym, *args, &block)
            if parent.respond_to?(sym)
              parent.send(sym, *args, &block)
            else
              super
            end
          end

          include Capistrano::Configuration::AliasTask
          include Capistrano::Configuration::Namespaces
          undef :desc, :next_description
        end

        class NamespaceContext
          extend Forwardable

          # The namespace that this context is currently attached to.
          attr_reader :namespace

          # The applied task continuations.
          attr_accessor :task_continuations

          def_delegator :@namespace, :top
          def_delegator :@namespace, :fully_qualified_name
          def_delegator :@namespace, :find_task
          def_delegator :@namespace, :search_task
          def_delegator :@namespace, :default_task
          def_delegator :@namespace, :task_list

          def initialize(namespace)
            @namespace = namespace
            @task_continuations = []
          end

          # Delegates {#method_missing} calls for namespaces, tasks, and task continuations to the underlying namespace.
          def method_missing(sym, *args, &block)
            raise "this namespace context is no longer valid" if @namespace.nil?

            if @namespace.namespaces.key?(sym)
              ns_context = @namespace.send(sym, *args, &block)
              @namespace = ns_context.namespace
              self
            elsif @namespace.tasks.key?(sym)
              if !@namespace.tasks[sym].continuation?
                # Build an aggregate continuation representing the execution of all the applied task continuations.
                current_continuation = Proc.new { |&block| block.call }

                @task_continuations.each do |task_continuation|
                  current_continuation = Execution.add_continuation(current_continuation) do |&block|
                    @namespace.execute_task(task_continuation, &block)
                  end
                end

                # Execute the task within the aggregate continuation.
                current_continuation.call { @namespace.send(sym, *args, &block) }
                @namespace = nil
                @task_continuations = []
              else
                ns_context = @namespace.send(sym, *args, &block)
                @task_continuations.concat(ns_context.task_continuations)
              end

              self
            else
              super
            end
          end

          # Resets the underlying namespace to the top-level namespace.
          def top
            @namespace = @namespace.top
            self
          end
        end
    end
  end
end

module Kernel
  class << self
    alias_method :method_added_without_capistrano, :method_added

    # Detect method additions to Kernel and remove them in the Namespace class
    def method_added(name)
      result = method_added_without_capistrano(name)
      return result if self != Kernel

      namespace = Capistrano::Configuration::Namespaces::Namespace

      if namespace.method_defined?(name) && namespace.method(name).owner == Kernel
        namespace.send :undef_method, name
      end

      result
    end
  end
end
