module Capistrano
  class Configuration
    class Question

      def initialize(env, key, default, options = {})
        @env, @key, @default, @options = env, key, default, options
      end

      def call
        ask_question
        save_response
      end

      private
      attr_reader :env, :key, :default, :options

      def ask_question
        $stdout.print question
      end

      def save_response
        env.set(key, value_or_default)
      end

      def value_or_default
        if response.empty?
          default
        else
          response
        end
      end

      def response
        return @response if defined? @response
        return @response = $stdin.gets.chomp if echo?
        @response = $stdin.noecho(&:gets).chomp.tap{$stdout.print "\n"}
      end

      def question
        I18n.t(:question, key: key, default_value: default, scope: :capistrano)
      end

      def echo?
        (options || {}).fetch(:echo, true)
      end
    end
  end
end
