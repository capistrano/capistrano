require "capistrano/proc_helpers"
require "delegate"

module Capistrano
  class Configuration
    # Decorates a Variables object to additionally perform an optional set of
    # user-supplied validation rules. Each rule for a given key is invoked
    # immediately whenever `set` is called with a value for that key.
    #
    # If `set` is called with a block, validation is not performed immediately.
    # Instead, the validation rules are invoked the first time `fetch` is used
    # to access the value.
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
        if value.nil? && callable_without_parameters?(block)
          super(key, nil, &assert_valid_later(key, &block))
        else
          assert_valid_now(key, block || value)
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

      # Wrap a block with a proc that validates the value of the block. This
      # allows us to defer validation until the time the value is requested.
      def assert_valid_later(key)
        lambda do
          value = yield
          assert_valid_now(key, value)
          value
        end
      end

      # Runs all validation rules registered for the given key against the
      # user-supplied value for that variable. If no validator raises an
      # exception, the value is assumed to be valid.
      def assert_valid_now(key, value)
        return unless validators.key?(key)

        validators[key].each do |validator|
          validator.call(key, value)
        end
      end
    end
  end
end
