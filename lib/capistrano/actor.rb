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
