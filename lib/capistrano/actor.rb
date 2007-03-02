require 'erb'
require 'capistrano/command'
require 'capistrano/transfer'
require 'capistrano/gateway'
require 'capistrano/ssh'
require 'capistrano/utils'

module Capistrano

  # An Actor is the entity that actually does the work of determining which
  # servers should be the target of a particular task, and of executing the
  # task on each of them in parallel. An Actor is never instantiated
  # directly--rather, you create a new Configuration instance, and access the
  # new actor via Configuration#actor.
  class Actor
    # Streams the result of the command from all servers that are the target of the
    # current task. All these streams will be joined into a single one,
    # so you can, say, watch 10 log files as though they were one. Do note that this
    # is quite expensive from a bandwidth perspective, so use it with care.
    #
    # Example:
    #
    #   desc "Run a tail on multiple log files at the same time"
    #   task :tail_fcgi, :roles => :app do
    #     stream "tail -f #{shared_path}/log/fastcgi.crash.log"
    #   end
    def stream(command)
      run(command) do |ch, stream, out|
        puts out if stream == :out
        if stream == :err
          puts "[err : #{ch[:host]}] #{out}"
          break
        end
      end
    end

    # Deletes the given file from all servers targetted by the current task.
    # If <tt>:recursive => true</tt> is specified, it may be used to remove
    # directories.
    def delete(path, options={})
      cmd = "rm -%sf #{path}" % (options[:recursive] ? "r" : "")
      run(cmd, options)
    end

    # Executes the given command on the first server targetted by the current
    # task, collects it's stdout into a string, and returns the string.
    def capture(command, options={})
      output = ""
      run(command, options.merge(:once => true)) do |ch, stream, data|
        case stream
        when :out then output << data
        when :err then raise "error processing #{command.inspect}: #{data.inspect}"
        end
      end
      output
    end

    # Renders an ERb template and returns the result. This is useful for
    # dynamically building documents to store on the remote servers.
    #
    # Usage:
    #
    #   render("something", :foo => "hello")
    #     look for "something.rhtml" in the current directory, or in the
    #     capistrano/recipes/templates directory, and render it with
    #     foo defined as a local variable with the value "hello".
    #
    #   render(:file => "something", :foo => "hello")
    #     same as above
    #
    #   render(:template => "<%= foo %> world", :foo => "hello")
    #     treat the given string as an ERb template and render it with
    #     the given hash of local variables active.
    def render(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      options[:file] = args.shift if args.first.is_a?(String)
      raise ArgumentError, "too many parameters" unless args.empty?

      case
        when options[:file]
          file = options.delete :file
          unless file[0] == ?/
            dirs = [".",
              File.join(File.dirname(__FILE__), "recipes", "templates")]
            dirs.each do |dir|
              if File.file?(File.join(dir, file))
                file = File.join(dir, file)
                break
              elsif File.file?(File.join(dir, file + ".rhtml"))
                file = File.join(dir, file + ".rhtml")
                break
              end
            end
          end

          render options.merge(:template => File.read(file))

        when options[:template]
          erb = ERB.new(options[:template])
          b = Proc.new { binding }.call
          options.each do |key, value|
            next if key == :template
            eval "#{key} = options[:#{key}]", b
          end
          erb.result(b)

        else
          raise ArgumentError, "no file or template given for rendering"
      end
    end
  end
end
