require 'capistrano/recipes/deploy/strategy/base'
require 'fileutils'
require 'tempfile'  # Dir.tmpdir

module Capistrano
  module Deploy
    module Strategy

      # This class implements the strategy for deployments which work
      # by preparing the source code locally, compressing it, copying the
      # file to each target host, and uncompressing it to the deployment
      # directory.
      #
      # By default, the SCM checkout command is used to obtain the local copy
      # of the source code. If you would rather use the export operation,
      # you can set the :copy_strategy variable to :export.
      #
      #   set :copy_strategy, :export
      #
      # For even faster deployments, you can set the :copy_cache variable to
      # true. This will cause deployments to do a new checkout of your
      # repository to a new directory, and then copy that checkout. Subsequent
      # deploys will just resync that copy, rather than doing an entirely new
      # checkout. Additionally, you can specify file patterns to exclude from
      # the copy when using :copy_cache; just set the :copy_exclude variable
      # to a file glob (or an array of globs).
      #
      #   set :copy_cache, true
      #   set :copy_exclude, ".git/*"
      #
      # Note that :copy_strategy is ignored when :copy_cache is set. Also, if
      # you want the copy cache put somewhere specific, you can set the variable
      # to the path you want, instead of merely 'true':
      #
      #   set :copy_cache, "/tmp/caches/myapp"
      #
      # This deployment strategy also supports a special variable,
      # :copy_compression, which must be one of :gzip, :bz2, or
      # :zip, and which specifies how the source should be compressed for
      # transmission to each host.
      #
      # By default, files will be transferred across to the remote machines via 'sftp'. If you prefer
      # to use 'scp' you can set the :copy_via variable to :scp.
      #
      #   set :copy_via, :scp
      #
      # There is a possibility to pass a build command that will get
      # executed if your code needs to be compiled or something needs to be
      # done before the code is ready to run.
      #
      #   set :build_script, "make all"
      #
      # Note that if you use :copy_cache, the :build_script is used on the
      # cache and thus you get faster compilation if your script does not
      # recompile everything.
      class Copy < Base
        # Obtains a copy of the source code locally (via the #command method),
        # compresses it to a single file, copies that file to all target
        # servers, and uncompresses it on each of them into the deployment
        # directory.
        def deploy!
          copy_cache ? run_copy_cache_strategy : run_copy_strategy

          create_revision_file
          compress_repository
          distribute!
        ensure
          rollback_changes
        end

        def build directory
          execute "running build script on #{directory}" do
            Dir.chdir(directory) { system(build_script) }
          end if build_script
        end

        def check!
          super.check do |d|
            d.local.command(source.local.command) if source.local.command
            d.local.command(compress(nil, nil).first)
            d.remote.command(decompress(nil).first)
          end
        end

        # Returns the location of the local copy cache, if the strategy should
        # use a local cache + copy instead of a new checkout/export every
        # time. Returns +nil+ unless :copy_cache has been set. If :copy_cache
        # is +true+, a default cache location will be returned.
        def copy_cache
          @copy_cache ||= configuration[:copy_cache] == true ?
            File.expand_path(configuration[:application], Dir.tmpdir) :
            File.expand_path(configuration[:copy_cache], Dir.pwd) rescue nil
        end

        private

          def run_copy_cache_strategy
            copy_repository_to_local_cache
            build copy_cache
            copy_cache_to_staging_area
          end

          def run_copy_strategy
            copy_repository_to_server
            build destination
            remove_excluded_files if copy_exclude.any?
          end

          def execute description, &block
            logger.debug description
            handle_system_errors &block
          end

          def handle_system_errors &block
            block.call
            raise_command_failed if last_command_failed?
          end

          def refresh_local_cache
            execute "refreshing local cache to revision #{revision} at #{copy_cache}" do
              system(source.sync(revision, copy_cache))
            end
          end

          def create_local_cache
            execute "preparing local cache at #{copy_cache}" do
              system(source.checkout(revision, copy_cache))
            end
          end

          def raise_command_failed
            raise Capistrano::Error, "shell command failed with return code #{$?}"
          end

          def last_command_failed?
            $? != 0
          end

          def copy_cache_to_staging_area
            execute "copying cache to deployment staging area #{destination}" do
              create_destination
              Dir.chdir(copy_cache) { copy_files(queue_files) }
            end
          end

          def create_destination
            FileUtils.mkdir_p(destination)
          end

          def copy_files files
            files.each { |name| process_file(name) }
          end

          def process_file name
            send "copy_#{filetype(name)}", name
          end

          def filetype name
            filetype = File.ftype name
            filetype = "file" unless ["link", "directory"].include? filetype
            filetype
          end

          def copy_link name
            FileUtils.ln_s(File.readlink(name), File.join(destination, name))
          end

          def copy_directory name
            FileUtils.mkdir(File.join(destination, name))
            copy_files(queue_files(name))
          end

          def copy_file name
            FileUtils.ln(name, File.join(destination, name))
          end

          def queue_files directory=nil
            Dir.glob(pattern_for(directory), File::FNM_DOTMATCH).reject! { |file| excluded_files_contain? file }
          end

          def pattern_for directory
            !directory.nil? ? "#{escape_globs(directory)}/*" : "*"
          end

          def escape_globs path
            path.gsub(/[*?{}\[\]]/, '\\\\\\&')
          end

          def excluded_files_contain? file
            copy_exclude.any? { |p| File.fnmatch(p, file) } or [ ".", ".."].include? File.basename(file)
          end

          def copy_repository_to_server
            execute "getting (via #{copy_strategy}) revision #{revision} to #{destination}" do
              copy_repository_via_strategy
            end
          end

          def copy_repository_via_strategy
              system(command)
          end

          def remove_excluded_files
            logger.debug "processing exclusions..."

            copy_exclude.each do |pattern|
              delete_list = Dir.glob(File.join(destination, pattern), File::FNM_DOTMATCH)
              # avoid the /.. trap that deletes the parent directories
              delete_list.delete_if { |dir| dir =~ /\/\.\.$/ }
              FileUtils.rm_rf(delete_list.compact)
            end
          end

          def create_revision_file
            File.open(File.join(destination, "REVISION"), "w") { |f| f.puts(revision) }
          end

          def compress_repository
            execute "Compressing #{destination} to #{filename}" do
              Dir.chdir(copy_dir) { system(compress(File.basename(destination), File.basename(filename)).join(" ")) }
            end
          end

          def rollback_changes
            FileUtils.rm filename rescue nil
            FileUtils.rm_rf destination rescue nil
          end

          def copy_repository_to_local_cache
            return refresh_local_cache if File.exists?(copy_cache)
            create_local_cache
          end

          def build_script
            configuration[:build_script]
          end

          # Specify patterns to exclude from the copy. This is only valid
          # when using a local cache.
          def copy_exclude
            @copy_exclude ||= Array(configuration.fetch(:copy_exclude, []))
          end

          # Returns the basename of the release_path, which will be used to
          # name the local copy and archive file.
          def destination
            @destination ||= File.join(copy_dir, File.basename(configuration[:release_path]))
          end

          # Returns the value of the :copy_strategy variable, defaulting to
          # :checkout if it has not been set.
          def copy_strategy
            @copy_strategy ||= configuration.fetch(:copy_strategy, :checkout)
          end

          # Should return the command(s) necessary to obtain the source code
          # locally.
          def command
            @command ||= case copy_strategy
            when :checkout
              source.checkout(revision, destination)
            when :export
              source.export(revision, destination)
            end
          end

          # Returns the name of the file that the source code will be
          # compressed to.
          def filename
            @filename ||= File.join(copy_dir, "#{File.basename(destination)}.#{compression.extension}")
          end

          # The directory to which the copy should be checked out
          def copy_dir
            @copy_dir ||= File.expand_path(configuration[:copy_dir] || Dir.tmpdir, Dir.pwd)
          end

          # The directory on the remote server to which the archive should be
          # copied
          def remote_dir
            @remote_dir ||= configuration[:copy_remote_dir] || "/tmp"
          end

          # The location on the remote server where the file should be
          # temporarily stored.
          def remote_filename
            @remote_filename ||= File.join(remote_dir, File.basename(filename))
          end

          # A struct for representing the specifics of a compression type.
          # Commands are arrays, where the first element is the utility to be
          # used to perform the compression or decompression.
          Compression = Struct.new(:extension, :compress_command, :decompress_command)

          # The compression method to use, defaults to :gzip.
          def compression
            remote_tar = configuration[:copy_remote_tar] || 'tar'
            local_tar = configuration[:copy_local_tar] || 'tar'

            type = configuration[:copy_compression] || :gzip
            case type
            when :gzip, :gz   then Compression.new("tar.gz",  [local_tar, 'czf'], [remote_tar, 'xzf'])
            when :bzip2, :bz2 then Compression.new("tar.bz2", [local_tar, 'cjf'], [remote_tar, 'xjf'])
            when :zip         then Compression.new("zip",     %w(zip -qyr), %w(unzip -q))
            else raise ArgumentError, "invalid compression type #{type.inspect}"
            end
          end

          # Returns the command necessary to compress the given directory
          # into the given file.
          def compress(directory, file)
            compression.compress_command + [file, directory]
          end

          # Returns the command necessary to decompress the given file,
          # relative to the current working directory. It must also
          # preserve the directory structure in the file.
          def decompress(file)
            compression.decompress_command + [file]
          end

          def decompress_remote_file
            run "cd #{configuration[:releases_path]} && #{decompress(remote_filename).join(" ")} && rm #{remote_filename}"
          end

          # Distributes the file to the remote servers
          def distribute!
            args = [filename, remote_filename]
            args << { :via => configuration[:copy_via] } if configuration[:copy_via]

            upload(*args)
            decompress_remote_file
          end
      end

    end
  end
end
