module Capistrano
  class Configuration
    # Decorates a Variables object to additionally perform an optional set of
    # user-supplied validation rules. Each rule for a given key is invoked
    # immediately whenever `set` is called for that key.
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
      def initialize(variables)
        super(variables)
        @validators = {}
      end

      # Decorate Variables#set to add validation behavior.
      def set(key, value=nil, &block)
        assert_valid(key, block || value)
        super
      end

      # Register a validation rule for the given key.
      def validate(key, &validator)
        vs = (validators[key] || [])
        vs << validator
        validators[key] = vs
      end

      private

      attr_reader :validators

      # Runs all validation rules registered for the given key against the
      # user-supplied value for that variable (which may be a proc). If no
      # validator raises an exception, the value is assumed to be valid.
      def assert_valid(key, value_or_proc)
        return unless validators.key?(key)

        validators[key].each do |validator|
          validator.call(key, value_or_proc)
        end
      end
    end
  end
end
