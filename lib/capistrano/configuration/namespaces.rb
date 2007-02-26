require 'capistrano/task_definition'

module Capistrano
  class Configuration
    module Namespaces
      def self.included(base)
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
        @next_description = nil
      end
      private :initialize_with_namespaces

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

      # Open a namespace in which to define new tasks. If the namespace was
      # defined previously, it will be reopened, otherwise a new namespace
      # will be created for the given name.
      def namespace(name, &block)
        name = name.to_sym
        raise ArgumentError, "expected a block" unless block_given?

        namespace_already_defined = namespaces.key?(name)
        if all_methods.include?(name.to_s) && !namespace_already_defined
          thing = tasks.key?(name) ? "task" : "method"
          raise ArgumentError, "defining a namespace named `#{name}' would shadow an existing #{thing} with that name"
        end

        namespaces[name] ||= Namespace.new(name, self)
        namespaces[name].instance_eval(&block)

        # make sure any open description gets terminated
        namespaces[name].desc(nil)

        if !namespace_already_defined
          metaclass = class << self; self; end
          metaclass.send(:define_method, name) { namespaces[name] }
        end
      end

      # Describe a new task. If a description is active (see #desc), it is added
      # to the options under the <tt>:desc</tt> key. The new task is added to
      # the namespace.
      def task(name, options={}, &block)
        name = name.to_sym
        raise ArgumentError, "expected a block" unless block_given?

        task_already_defined = tasks.key?(name)
        if all_methods.include?(name.to_s) && !task_already_defined
          thing = namespaces.key?(name) ? "namespace" : "method"
          raise ArgumentError, "defining a task named `#{name}' would shadow an existing #{thing} with that name"
        end

        tasks[name] = TaskDefinition.new(name, self, {:desc => @next_description}.merge(options), &block)
        @next_description = nil

        if !task_already_defined
          metaclass = class << self; self; end
          metaclass.send(:define_method, name) { execute_task(name, self) }
        end
      end

      private

        def all_methods
          public_methods.concat(protected_methods).concat(private_methods)
        end

      class Namespace
        def initialize(name, parent)
          @parent = parent
          @name = name
        end

        def role(*args)
          raise NotImplementedError, "roles cannot be defined in a namespace"
        end

        def respond_to?(sym)
          super || parent.respond_to?(sym)
        end

        def method_missing(sym, *args, &block)
          if parent.respond_to?(sym)
            parent.send(sym, *args, &block)
          else
            super
          end
        end

        include Capistrano::Configuration::Namespaces
      end
    end
  end
end