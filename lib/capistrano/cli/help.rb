module Capistrano
  class CLI
    module Help
      LINE_PADDING = 7
      MIN_MAX_LEN  = 30
      HEADER_LEN   = 60

      def self.included(base) #:nodoc:
        base.send :alias_method, :execute_requested_actions_without_help, :execute_requested_actions
        base.send :alias_method, :execute_requested_actions, :execute_requested_actions_with_help
      end

      def execute_requested_actions_with_help(config)
        if options[:tasks]
          task_list(config)
        elsif options[:explain]
          explain_task(config, options[:explain])
        else
          execute_requested_actions_without_help(config)
        end
      end

      def task_list(config) #:nodoc:
        tasks = config.task_list(:all)

        if tasks.empty?
          warn "There are no tasks available. Please specify a recipe file to load."
        else
          tasks = tasks.sort_by { |task| task.fully_qualified_name }

          longest = tasks.map { |task| task.fully_qualified_name.length }.max
          max_length = output_columns - longest - LINE_PADDING
          max_length = MIN_MAX_LEN if max_length < MIN_MAX_LEN

          tasks.each do |task|
            puts "cap %-#{longest}s # %s" % [task.fully_qualified_name, task.brief_description(max_length)]
          end

          puts
          puts "Extended help may be available for any of these tasks."
          puts "Type `#{$0} -e taskname' to view it."
        end
      end

      def explain_task(config, name) #:nodoc:
        task = config.find_task(name)
        if task.nil?
          warn "The task `#{name}' does not exist."
        else
          puts "-" * HEADER_LEN
          puts "cap #{name}"
          puts "-" * HEADER_LEN

          if task.description.empty?
            puts "There is no description for this task."
          else
            task.description.each_line do |line|
              lines = line.gsub(/(.{1,#{output_columns}})(?:\s+|\Z)/, "\\1\n").split(/\n/)
              if lines.empty?
                puts
              else
                puts lines
              end
            end
          end

          puts
        end
      end

      def output_columns #:nodoc:
        @output_columns ||= self.class.ui.output_cols > 80 ? 80 : self.class.ui.output_cols
      end
    end
  end
end