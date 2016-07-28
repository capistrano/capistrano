require "capistrano/proc_helpers"
require "delegate"

module Capistrano
  class Configuration
    # Decorates a Variables object to additionally perform an optional set of
    # user-supplied validation rules. Each rule for a given key is invoked
    # immediately whenever `set` is called with a value for that key.
    #
    # If `set` is called with a callable value or a block, validation is not
    # performed immediately. Instead, the validation rules are invoked the first
    # time `fetch` is used to access the value.
    #
    # A rule is simply a block that accepts two arguments: key and value. It is
    # up to the rule to raise an exception when it deems the value is invalid
    # (or just print a warning).
    #
    # Rules can be registered using the DSL like this:
    #
    #   validate(:my_key) do |key, value|
    #     # rule goes here
    #   end
    #
    class ValidatedVariables < SimpleDelegator
      include Capistrano::ProcHelpers

      def initialize(variables)
        super(variables)
        @validators = {}
      end

      # Decorate Variables#set to add validation behavior.
      def set(key, value=nil, &block)
        assert_value_or_block_not_both(value, block)

        # Skip validation behavior if no validators are registered for this key
        return super unless validators.key?(key)

        value_to_evaluate = block || value

        if callable_without_parameters?(value_to_evaluate)
          add_validation_to_call_method(key, value_to_evaluate)
          super(key, value_to_evaluate, &nil)
        else
          assert_valid(key, value_to_evaluate)
          super
        end
      end

      # Register a validation rule for the given key.
      def validate(key, &validator)
        vs = (validators[key] || [])
        vs << validator
        validators[key] = vs
      end

      private

      attr_reader :validators

      # Patch the #call method of a callable object with logic that validates
      # the return value. This allows us to defer validation until the time the
      # callable's value is requested.
      #
      # Essentially we are changing the behavior of #call but leaving the rest
      # of the callable object as-is. This is important because the callable
      # might be a Question object, and want it to remain a Question object so
      # that Configuration#is_question? still works.
      #
      def add_validation_to_call_method(key, callable)
        # Note that `self` changes meaning inside the `define_singleton_method`
        # block, so we have to explicitly assign it to a variable to retain
        # access to it.
        variables = self

        callable.define_singleton_method(:call) do
          value = super()
          # Need to use `send` because #assert_valid is private and we can't
          # access using the normal `self.assert_valid` in this context.
          variables.send(:assert_valid, key, value)
          value
        end
      end

      # Runs all validation rules registered for the given key against the
      # user-supplied value for that variable. If no validator raises an
      # exception, the value is assumed to be valid.
      def assert_valid(key, value)
        validators[key].each do |validator|
          validator.call(key, value)
        end
      end

      def assert_value_or_block_not_both(value, block)
        unless value.nil? || block.nil?
          raise Capistrano::ValidationError,
                "Value and block both passed to Configuration#set"
        end
      end
    end
  end
end
