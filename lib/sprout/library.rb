
module Sprout

  ##
  # Sprout Libraries provide support for sharing and versioning raw or 
  # pre-compiled source code across projects.
  #
  # Sprout Libraries give us the ability to include raw (or pre-compiled) source
  # code directly within a Ruby Gem, or to refer to an archive somewhere on
  # the internet.
  #
  # A Sprout Library is made up of two components:
  #
  # * Specification: The description of the library
  # * Source Code: Raw or pre-compiled (swc, jar, abc)
  #
  # = Specification
  # Libraries can be added to local or remote file targets in a 
  # Sprout::Specification. When calling add_library, one must provide the 
  # library name (symbol that will be used from Rake) and a relative path (or 
  # Array of paths) from the Specification to the library file or directory.
  #
  # Following is an example of a Sprout::Specification that registers a SWC 
  # that will be distributed directly within a Ruby Gem:
  #
  #   Sprout::Specification.new do |s|
  #     s.name = "asunit4"
  #     s.version = "4.4.2"
  #     s.add_file_target do |f|
  #       f.add_library :swc, File.join('bin', "AsUnit-4.4.2.swc")
  #     end
  #   end
  #
  # Following is an example of a Sprout::Specification that registers a ZIP
  # archive that will be distributed separately from the Ruby Gem:
  #
  #   Sprout::Specification.new do |s|
  #     s.name = "asunit3"
  #     s.version = "3.0.0"
  #     s.add_remote_file_target do |f|
  #       f.url = "https://github.com/patternpark/asunit/tree/3.0.0"
  #       f.md5 = "abcdefghijklmnopqrstuvwxyz"
  #       f.add_library :swc, "bin/AsUnit-3.0.1.zip"
  #     end
  #   end
  #
  # Libraries can be consumed from any Rakefile without concern for how
  # the source code is distributed. Following is an example Rake task
  # that uses the AsUnit 4.0 Library:
  #
  #   # Define the library Rake::Task:
  #   library :asunit4
  #
  #   # Add the library as a dependency from another task
  #   # that should know how to properly associate the files:
  #   mxmlc 'bin/SomeProject.swf' => :asunit4 do |t|
  #     t.input = 'src/SomeProject.as'
  #   end
  #
  # When the library task is executed, the library should be resolved and 
  # expanded into the project. When the mxmlc task is executed, the installed 
  # library should be associated with the compilation command.
  #   
  # ---
  # 
  # Previous Topic: {Sprout::Generator}
  #
  # Next Topic: {Sprout::Executable}
  #
  # ---
  # 
  # @see Sprout::Generator
  # @see Sprout::Executable
  # @see Sprout::Specification
  # @see Sprout::RubyFeature
  # @see Sprout::System
  #
  class Library
    include RubyFeature

    TASK_NAME = :resolve_sprout_libraries

    attr_accessor :file_target
    attr_accessor :installed_project_path
    attr_accessor :name
    attr_accessor :path
    attr_accessor :pkg_name
    attr_accessor :pkg_version
    attr_accessor :platform

    class << self
      ##
      # Set the path within a project
      # where libraries should be loaded.
      #
      # From top of your Rakefile, you can 
      # set this value with:
      #
      #   Sprout::Library.project_path = 'libs'
      #
      def project_path=(path)
        @project_path = path
      end

      ##
      # The path within a project where 
      # libraries should be added.
      #
      # Defaults to 'lib'
      #
      # From anywhere in your Rakefile, you can output
      # this value with:
      #
      #   puts ">> Library Project Path: #{Sprout::Library.project_path}"
      #
      def project_path
        @project_path ||= 'lib'
      end

      ##
      # Create Rake tasks that will load and install
      # a particular library into the current project.
      #
      # This method is usually accessed from the global
      # library helper.
      #
      #   library :asunit4
      #
      def define_task name=nil, pkg_name=nil, pkg_version=nil
        library = Sprout::Library.load name, pkg_name, pkg_version
        library.create_installation_tasks
      end
    end

    def initialize params=nil
      params.each {|key,value| self.send("#{key}=", value)} unless params.nil?
      super()
    end

    ##
    # Returns the outer Rake::Task which is invokable.
    def create_installation_tasks
      define_lib_dir_task_if_necessary project_path
      create_project_tasks
      create_outer_task
    end

    def create_outer_task
      t = task pkg_name
      # This helps executable rake tasks decide if they
      # want to do something special for library tasks.
      t.sprout_entity = self
      class << t
        def sprout_library?
          !sprout_entity.nil? &&
            sprout_entity.is_a?(Sprout::Library)
        end
      end
      t
    end

    private

    def project_path
      Sprout::Library.project_path
    end

    def create_project_tasks
      if path.is_a?(Array)
        # TODO: Need to add support for merging these directories
        # rather than simply clobbering...
        @instaled_project_path = path.collect { |single_path| define_project_path_task pkg_name, single_path }
      else
        @installed_project_path = define_project_path_task pkg_name, path
      end
    end

    def define_lib_dir_task_if_necessary dir
      if !File.exists?(dir)
        define_file_task dir do
          FileUtils.mkdir_p dir
          Sprout.stdout.puts ">> Created directory at: #{dir}"
        end
      end
    end

    def define_project_path_task pkg_name, path
      install_path = "#{project_path}/#{pkg_name}"
      if File.directory?(path)
        define_directory_copy_task path, install_path
      else
        define_file_copy_task path, install_path
      end
    end

    def define_directory_copy_task path, install_path
      define_file_task install_path do
        FileUtils.cp_r path, install_path
        Sprout.stdout.puts ">> Copied files from: (#{path}) to: (#{install_path})"
      end
      install_path
    end

    def define_file_copy_task path, install_path
      task_name = "#{install_path}/#{File.basename(path)}"
      define_file_task task_name do
        FileUtils.mkdir_p install_path
        FileUtils.cp path, "#{install_path}/"
        Sprout.stdout.puts ">> Copied file from: (#{path}) to: (#{task_name})"
      end
      task_name
    end

    def define_file_task name
      file name do |t|
        yield if block_given?
      end
      task Sprout::Library::TASK_NAME => name
    end
  end

end

# From within a Rakefile, you can load libraries
# by calling this method:
#
#   library :asunit4
#
# Or, if you would like to specify which registered
# library to pull from the identified package (by name):
#
#   library :asunit4, :src
#
# Or, if you'd like to specify version requirements:
#
#   library :asunit4, :swc, '>= 4.2.pre'
#
# It's important to note that libraries must also
# be defined in your Gemfile like:
#
#   gem "asunit4", ">= 4.2.pre"
#
# Libraries are generally then added to compiler tasks
# as Rake dependencies like:
#
#   mxmlc 'bin/SomeRunner.swf' => [:asunit4] do |t|
#     t.input = 'src/SomeRunner.as'
#     t.source_path << 'test'
#   end
#
def library pkg_name, name=nil, version=nil
  Sprout::Library.define_task name, pkg_name, version
end

