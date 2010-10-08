
module Sprout
  class Library
    include RubyFeature

    TASK_NAME = :resolve_sprout_libraries

    attr_accessor :file_target
    attr_accessor :installed_project_path
    attr_accessor :name
    attr_accessor :path
    attr_accessor :pkg_name
    attr_accessor :pkg_version

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
          Sprout::Log.puts ">> Created directory at: #{dir}"
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
        Sprout::Log.puts ">> Copied files from: (#{path}) to: (#{install_path})"
      end
      install_path
    end

    def define_file_copy_task path, install_path
      task_name = "#{install_path}/#{File.basename(path)}"
      define_file_task task_name do
        FileUtils.mkdir_p install_path
        FileUtils.cp path, "#{install_path}/"
        Sprout::Log.puts ">> Copied file from: (#{path}) to: (#{task_name})"
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

