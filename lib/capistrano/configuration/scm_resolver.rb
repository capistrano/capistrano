module Capistrano
  class Configuration
    # In earlier versions of Capistrano, users would specify the desired SCM
    # implementation using `set :scm, :git`, for example. Capistrano would then
    # load the matching .rb file based on this variable.
    #
    # Now we expect users to explicitly `require` and call `new` on the desired
    # SCM implementation in their Capfile. The `set` technique is deprecated.
    #
    # This SCMResolver class takes care of managing the transition from the old
    # to new system. It maintains the legacy behavior, but prints deprecation
    # warnings when it is used.
    #
    # To maintain backwards compatibility, the resolver will load the Git SCM by
    # if default it determines that no SCM has been explicitly specified or
    # loaded. To force no SCM to be used at all, use `set :scm, nil`. This hack
    # won't be necessary once backwards compatibility is removed in a future
    # version.
    #
    # TODO: Remove this class entirely in Capistrano 4.0.
    #
    class SCMResolver
      DEFAULT_GIT = :"default-git"

      include Capistrano::DSL

      def resolve
        return if scm_name.nil?
        set(:scm, :git) if using_default_scm?

        print_deprecation_warnings_if_applicable

        # Note that `scm_plugin_installed?` comes from Capistrano::DSL
        if scm_plugin_installed?
          delete(:scm)
          return
        end

        if built_in_scm_name?
          load_built_in_scm
        else
          # Compatibility with existing 3.x third-party SCMs
          register_legacy_scm_hooks
          load_legacy_scm_by_name
        end
      end

      private

      def using_default_scm?
        return @using_default_scm if defined? @using_default_scm
        @using_default_scm = (fetch(:scm) == DEFAULT_GIT)
      end

      def scm_name
        fetch(:scm)
      end

      def load_built_in_scm
        require "capistrano/scm/#{scm_name}"
        scm_class = Object.const_get(built_in_scm_plugin_class_name)
        # We use :load_immediately because we are initializing the SCM plugin
        # late in the load process and therefore can't use the standard
        # load:defaults technique.
        install_plugin(scm_class, load_immediately: true)
      end

      def load_legacy_scm_by_name
        load("capistrano/#{scm_name}.rb")
      end

      def third_party_scm_name?
        !built_in_scm_name?
      end

      def built_in_scm_name?
        %w(git hg svn).include?(scm_name.to_s.downcase)
      end

      def built_in_scm_plugin_class_name
        "Capistrano::SCM::#{scm_name.to_s.capitalize}"
      end

      # rubocop:disable Style/GuardClause
      def register_legacy_scm_hooks
        if Rake::Task.task_defined?("deploy:new_release_path")
          after "deploy:new_release_path", "#{scm_name}:create_release"
        end

        if Rake::Task.task_defined?("deploy:check")
          before "deploy:check", "#{scm_name}:check"
        end

        if Rake::Task.task_defined?("deploy:set_current_revision")
          before "deploy:set_current_revision",
                 "#{scm_name}:set_current_revision"
        end
      end
      # rubocop:enable Style/GuardClause

      def print_deprecation_warnings_if_applicable
        if using_default_scm?
          warn_add_git_to_capfile unless scm_plugin_installed?
        elsif built_in_scm_name?
          warn_set_scm_is_deprecated
        elsif third_party_scm_name?
          warn_third_party_scm_must_be_upgraded
        end
      end

      def warn_set_scm_is_deprecated
        $stderr.puts(<<-MESSAGE)
[Deprecation Notice] `set :scm, #{scm_name.inspect}` is deprecated.
To ensure your project is compatible with future versions of Capistrano,
remove the :scm setting and instead add these lines to your Capfile after
`require "capistrano/deploy"`:

    require "capistrano/scm/#{scm_name}"
    install_plugin #{built_in_scm_plugin_class_name}

MESSAGE
      end

      def warn_add_git_to_capfile
        $stderr.puts(<<-MESSAGE)
[Deprecation Notice] Future versions of Capistrano will not load the Git SCM
plugin by default. To silence this deprecation warning, add the following to
your Capfile after `require "capistrano/deploy"`:

    require "capistrano/scm/git"
    install_plugin Capistrano::SCM::Git

MESSAGE
      end

      def warn_third_party_scm_must_be_upgraded
        $stderr.puts(<<-MESSAGE)
[Deprecation Notice] `set :scm, #{scm_name.inspect}` is deprecated.
To ensure this custom SCM will work with future versions of Capistrano,
please upgrade it to a version that uses the new SCM plugin mechanism
documented here:

http://capistranorb.com/documentation/advanced-features/custom-scm

MESSAGE
      end
    end
  end
end
