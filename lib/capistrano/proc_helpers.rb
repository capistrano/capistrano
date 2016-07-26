module Capistrano
  module ProcHelpers
    module_function

    # Tests whether the given object appears to respond to `call` with
    # zero parameters. In Capistrano, such a proc is used to represent a
    # "deferred value". That is, a value that is resolved by invoking `call` at
    # the time it is first needed.
    def callable_without_parameters?(x)
      x.respond_to?(:call) && (!x.respond_to?(:arity) || x.arity.zero?)
    end
  end
end
