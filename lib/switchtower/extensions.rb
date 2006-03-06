require 'switchtower/actor'

module SwitchTower
  class ExtensionProxy
    def initialize(actor, mod)
      @actor = actor
      extend(mod)
    end

    def method_missing(sym, *args, &block)
      @actor.send(sym, *args, &block)
    end
  end

  EXTENSIONS = {}

  def self.plugin(name, mod)
    return false if EXTENSIONS.has_key?(name)

    SwitchTower::Actor.class_eval <<-STR, __FILE__, __LINE__+1
      def #{name}
        @__#{name}_proxy ||= SwitchTower::ExtensionProxy.new(self, SwitchTower::EXTENSIONS[#{name.inspect}])
      end
    STR

    EXTENSIONS[name] = mod
    return true
  end

  def self.remove_plugin(name)
    if EXTENSIONS.delete(name)
      SwitchTower::Actor.send(:remove_method, name)
      return true
    end

    return false
  end
end