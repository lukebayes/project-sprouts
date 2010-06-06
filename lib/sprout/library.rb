
module Sprout
  module Library
    TASK_NAME = :resolve_sprout_libraries

    include RubyFeature

    class << self

      ##
      # Set the path within a project
      # where libraries should be loaded.
      def project_path=(path)
        @project_path = path
      end

      ##
      # The path within a project where 
      # libraries should be added.
      #
      # Defaults to 'lib'
      def project_path
        @project_path ||= 'lib'
      end

      ##
      # Create Rake tasks that will load and install
      # a particular library.
      def define_task pkg_name, type=nil, version=nil
        library = Sprout::Library.load type, pkg_name, version
        library.installation_task = task pkg_name

        define_lib_dir_task_if_necessary
        path_or_paths = library.path
        if path_or_paths.is_a?(Array)
          # TODO: Need to add support for merging these directories
          # rather than simply clobbering...
          path_or_paths.each { |p| define_path_task pkg_name, library, p }
        else
          define_path_task pkg_name, library, path_or_paths
        end
        library
      end

      protected

      def define_lib_dir_task_if_necessary
        if !File.exists?(project_path)
          define_file_task project_path do
            FileUtils.mkdir_p project_path
            Sprout::Log.puts ">> Created directory at: #{project_path}"
          end
        end
      end

      def define_path_task pkg_name, library, path
        installation_path = "#{project_path}/#{pkg_name}"
        if File.directory?(path)
          define_directory_copy_task path, installation_path
        else
          define_file_copy_task path, installation_path
        end
      end

      def define_directory_copy_task path, installation_path
        define_file_task installation_path do
          FileUtils.cp_r path, installation_path
          Sprout::Log.puts ">> Copied files from: (#{path}) to: (#{installation_path})"
        end
      end

      def define_file_copy_task path, installation_path
        task_name = "#{installation_path}/#{File.basename(path)}"
        define_file_task task_name do
          FileUtils.mkdir_p installation_path
          FileUtils.cp path, "#{installation_path}/"
          Sprout::Log.puts ">> Copied file from: (#{path}) to: (#{task_name})"
        end
      end

      def define_file_task name
        file name do |t|
          yield if block_given?
        end
        task Sprout::Library::TASK_NAME => name
      end

    end

  end
end

# From within a Rakefile, you can load libraries
# by calling this shortcut:
#
#   library :asunit4
#
# Or, if you would like to specify which registered
# library to pull from the identified package:
#
#   library :asunit4, :src
#
# Or, if you'd like to specify version requirements:
#
#   library :asunit4, :swc, '>= 4.2.pre'
#
def library pkg_name, type=nil, version=nil
  puts ">> Library loaded!"
  Sprout::Library.define_task pkg_name, type, version
end

