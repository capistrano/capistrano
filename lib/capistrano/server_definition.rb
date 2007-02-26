module Capistrano
  class ServerDefinition
    attr_reader :host
    attr_reader :user
    attr_reader :port
    attr_reader :options

    def initialize(string, options={})
      @user, @host, @port = string.match(/^(?:([^;,:=]+)@|)(.*?)(?::(\d+)|)$/)[1,3]

      @options = options.dup
      @user = @options.delete(:user) || @user
      @port = @options.delete(:port) || @port

      @port = @port.to_i if @port
    end

    # Redefined, so that Array#uniq will work to remove duplicate server
    # definitions, based solely on their host names.
    def eql?(server)
      host == server.host
    end

    # Redefined, so that Array#uniq will work to remove duplicate server
    # definitions, based solely on their host names.
    def hash
      host.hash
    end
  end
end