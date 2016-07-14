require "rake/task"
module Rake
  class Task
    alias original_invoke_with_call_chain invoke_with_call_chain # :nodoc:
    def invoke_with_call_chain(task_args, invocation_chain) # :nodoc:
      if self.class.ancestors.include?(Capistrano::TaskEnhancements) && already_invoked
        file, line, = caller[2].split(":")
        colors = SSHKit::Color.new($stderr)
        $stderr.puts colors.colorize("Warning: Reinvoking `#{name}' from #{file}:#{line} - Task will be silently skipped.", :red)
        $stderr.puts colors.colorize("This behaviour is deprecated and will change in a future release.", :red)
        $stderr.puts colors.colorize("If this affects you, please come to this URL to discuss: https://github.com/capistrano/capistrano/issues/1686", :yellow)
      end
      original_invoke_with_call_chain(task_args, invocation_chain)
    end
  end
end
