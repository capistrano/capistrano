class DeploymentGenerator < Rails::Generator::NamedBase
  attr_reader :recipe_file

  def initialize(runtime_args, runtime_options = {})
    super
    @recipe_file = @args.shift || "deploy"
  end

  def manifest
    record do |m|
      m.directory "script"
      m.file "switchtower", File.join("script", "switchtower")
      m.directory "config"
      m.template "deploy.rb", File.join("config", "#{recipe_file}.rb")
      m.directory "lib/tasks"
      m.template "switchtower.rake", File.join("lib", "tasks", "switchtower.rake")
    end
  end

  protected

    # Override with your own usage banner.
    def banner
      "Usage: #{$0} deployment ApplicationName [recipe-name]\n" +
      "  (recipe-name defaults to \"deploy\")"
    end
end
