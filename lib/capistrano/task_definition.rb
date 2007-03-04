require 'capistrano/server_definition'

module Capistrano
  # Represents the definition of a single task.
  class TaskDefinition
    attr_reader :name, :namespace, :options, :body

    def initialize(name, namespace, options={}, &block)
      @name, @namespace, @options = name, namespace, options
      @body = block or raise ArgumentError, "a task requires a block"
      @servers = nil
    end

    # Returns the task's fully-qualified name, including the namespace
    def fully_qualified_name
      @fully_qualified_name ||= begin
        if namespace.default_task == self
          namespace.fully_qualified_name
        else
          [namespace.fully_qualified_name, name].compact.join(":")
        end
      end
    end

    # Returns the list of server definitions (_not_ connections to servers)
    # that are the target of this task.
    def servers(reevaluate=false)
      @servers = nil if reevaluate
      @servers ||=
        if hosts = find_hosts
          hosts.map { |host| ServerDefinition.new(host) }
        else
          apply_except(apply_only(find_servers_by_role)).uniq
        end
    end

    # Returns the description for this task, with newlines collapsed and
    # whitespace stripped. Returns the empty string if there is no
    # description for this task.
    def description(rebuild=false)
      @description = nil if rebuild
      @description ||= begin
        description = options[:desc] || ""
        description.strip.
          gsub(/\r\n/, "\n").
          gsub(/\\\n/, " ")
      end
    end

    # Returns the first sentence of the full description. If +max_length+ is
    # given, the result will be truncated if it is longer than +max_length+,
    # and an ellipsis appended.
    def brief_description(max_length=nil)
      brief = description[/^.*?\./] || description

      if max_length && brief.length > max_length
        brief = brief[0,max_length-3] + "..."
      end

      brief
    end

    private
      def find_servers_by_role
        roles = namespace.roles
        role_names = environment_values(:roles, true) || @options[:roles] || roles.keys
        Array(role_names).inject([]) do |list, name|
          name = name.to_sym
          raise ArgumentError, "task `#{fully_qualified_name}' references non-existant role `#{name}'" unless roles.key?(name)
          list.concat(roles[name])
        end
      end
      
      def find_hosts
        environment_values(:hosts) || @options[:hosts]
      end
      
      def environment_values(key, use_symbols = false)
        if variable = ENV[key.to_s.upcase]
          values = variable.split(",")
          use_symbols ? values.collect { |e| e.to_sym } : values
        end
      end
      
      def apply_only(roles)
        only = @options[:only] || {}
        roles.select do |role|
          only.all? { |key, value| role.options[key] == value }
        end
      end
      
      def apply_except(roles)
        except = @options[:except] || {}
        roles.reject do |role|
          except.any? { |key, value| role.options[key] == value }
        end
      end
  end
end