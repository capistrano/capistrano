module Capistrano
  # Base class for SCM strategy providers.
  #
  # @abstract
  #
  # @attr_reader [Rake] context
  #
  # @author Hartog de Mik
  #
  class SCM
    attr_reader :context

    # Provide a wrapper for the SCM that loads a strategy for the user.
    #
    # @param [Rake] context     The context in which the strategy should run
    # @param [Module] strategy  A module to include into the SCM instance. The
    #    module should provide the abstract methods of Capistrano::SCM
    #
    def initialize(context, strategy)
      @context = context
      singleton = class << self; self; end
      singleton.send(:include, strategy)
    end

    # Call test in context
    def test!(*args)
      context.test(*args)
    end

    # The repository URL according to the context
    def repo_url
      context.repo_url
    end

    # The repository path according to the context
    def repo_path
      context.repo_path
    end

    # The release path according to the context
    def release_path
      context.release_path
    end

    # Fetch a var from the context
    # @param [Symbol] variable The variable to fetch
    # @param [Object] default  The default value if not found
    #
    def fetch(*args)
      context.fetch(*args)
    end

    # @abstract
    #
    # Your implementation should check the existence of a cache repository on
    # the deployment target
    #
    # @return [Boolean]
    #
    def test
      raise NotImplementedError, "Your SCM strategy module should provide a #test method"
    end

    # @abstract
    #
    # Your implementation should check if the specified remote-repository is
    # available.
    #
    # @return [Boolean]
    #
    def check
      raise NotImplementedError, "Your SCM strategy module should provide a #check method"
    end

    # @abstract
    #
    # Create a (new) clone of the remote-repository on the deployment target
    #
    # @return void
    #
    def clone
      raise NotImplementedError, "Your SCM strategy module should provide a #clone method"
    end

    # @abstract
    #
    # Update the clone on the deployment target
    #
    # @return void
    #
    def update
      raise NotImplementedError, "Your SCM strategy module should provide a #update method"
    end

    # @abstract
    #
    # Copy the contents of the cache-repository onto the release path
    #
    # @return void
    #
    def release
      raise NotImplementedError, "Your SCM strategy module should provide a #release method"
    end

    # @abstract
    #
    # Identify the SHA of the commit that will be deployed.  This will most likely involve SshKit's capture method.
    #
    # @return void
    #
    def fetch_revision
      raise NotImplementedError, "Your SCM strategy module should provide a #fetch_revision method"
    end
  end
end
