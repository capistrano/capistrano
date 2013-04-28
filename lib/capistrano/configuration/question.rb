module Capistrano
  class Configuration
    class Question

      def initialize(env, key, default)
        @env, @key, @default = env, key, default
      end

      def call
        ask_question
        save_response
      end

      private
      attr_reader :env, :key, :default

      def ask_question
        $stdout.puts question
      end

      def save_response
        env.set(key, value)
      end

      def value
        if response.empty?
          default
        else
          response
        end
      end

      def response
        @response ||= $stdin.gets.chomp
      end

      def question
        I18n.t(:question, key: key, default_value: default, scope: :capistrano)
      end
    end
  end
end
