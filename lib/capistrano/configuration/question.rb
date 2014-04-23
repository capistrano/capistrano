module Capistrano
  class Configuration
    class Question

      def initialize(env, key, default, options = {})
        @env, @key, @default, @options = env, key, default, options
      end

      def call
        response = highline_ask(question) { |q| q.echo = echo? }
        save_response(value_or_default(response))
      end

      private
      attr_reader :env, :key, :default, :options

      def save_response(value)
        env.set(key, value)
      end

      def value_or_default(response)
        if response.empty?
          default
        else
          response
        end
      end

      def question
        I18n.t(:question, key: key, default_value: default, scope: :capistrano)
      end

      def echo?
        (options || {}).fetch(:echo, true)
      end

      def highline_ask(question, &block)
        # For compatibility, we call #to_s to unwrap HighLine::String and
        # return a regular String.
        HighLine.new.ask(question, &block).to_s
      end
    end
  end
end
