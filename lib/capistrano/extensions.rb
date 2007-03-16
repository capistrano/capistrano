module Capistrano
  class ExtensionProxy
    def initialize(config, mod)
      @config = config
      extend(mod)
    end

    def method_missing(sym, *args, &block)
      @config.send(sym, *args, &block)
    end
  end

  EXTENSIONS = {}

  def self.plugin(name, mod)
    return false if EXTENSIONS.has_key?(name)

    Capistrano::Configuration.class_eval <<-STR, __FILE__, __LINE__+1
      def #{name}
        @__#{name}_proxy ||= Capistrano::ExtensionProxy.new(self, Capistrano::EXTENSIONS[#{name.inspect}])
      end
    STR

    EXTENSIONS[name] = mod
    return true
  end

  def self.remove_plugin(name)
    if EXTENSIONS.delete(name)
      Capistrano::Configuration.send(:remove_method, name)
      return true
    end

    return false
  end

  def self.configuration(*args)
    warn "[DEPRECATION] Capistrano.configuration is deprecated. Use Capistrano::Configuration.instance instead"
    Capistrano::Configuration.instance(*args)
  end
end
