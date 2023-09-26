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
          super(key, assert_valid_later(key, value_to_evaluate), &nil)
        else
          assert_valid_now(key, value_to_evaluate)
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

      # Given a callable that provides a value, wrap the callable with another
      # object that responds to `call`. This new object will perform validation
      # and then return the original callable's value.
      #
      # If the callable is a `Question`, the object returned by this method will
      # also be a `Question` (a `ValidatedQuestion`, to be precise). This
      # ensures that `is_a?(Question)` remains true even after the validation
      # wrapper is applied. This is needed so that `Configuration#is_question?`
      # works as expected.
      #
      def assert_valid_later(key, callable)
        validation_callback = proc do
          value = callable.call
          assert_valid_now(key, value)
          value
        end

        if callable.is_a?(Question)
          ValidatedQuestion.new(validation_callback)
        else
          validation_callback
        end
      end

      # Runs all validation rules registered for the given key against the
      # user-supplied value for that variable. If no validator raises an
      # exception, the value is assumed to be valid.
      def assert_valid_now(key, value)
        validators[key].each do |validator|
          validator.call(key, value)
        end
      end

      def assert_value_or_block_not_both(value, block)
        return if value.nil? || block.nil?
        raise Capistrano::ValidationError,
              "Value and block both passed to Configuration#set"
      end

      class ValidatedQuestion < Question
        def initialize(validator)
          @validator = validator
        end

        def call
          @validator.call
        end
      end
    end
  end
end
