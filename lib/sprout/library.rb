
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
      def define_task pkg_name, type=nil, version=nil
        puts ">> INSIDE DEFINE: #{pkg_name}"
        
        library = Sprout::Library.load pkg_name.to_s, type, version
        library.create_installation_tasks
        library
      end
    end

    def initialize params=nil
      params.each {|key,value| self.send("#{key}=", value)} unless params.nil?
      super()
    end

    def create_installation_tasks
      define_lib_dir_task_if_necessary project_path

      @installed_project_path = create_project_tasks
      create_outer_task
    end

    def create_outer_task
      t = task pkg_name
      # This helps executable rake tasks decide if they
      # want to do something special for library tasks.
      t.sprout_type = :library
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
        path.collect { |single_path| define_path_task pkg_name, single_path }
      else
        define_path_task pkg_name, path
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

    def define_path_task pkg_name, path
      installation_path = "#{project_path}/#{pkg_name}"
      if File.directory?(path)
        define_directory_copy_task path, installation_path
      else
        define_file_copy_task path, installation_path
      end
    end

    def define_directory_copy_task path, installation_path
      define_file_task installation_path do
        puts ">> INSIDE DIR COPY WITH: #{installation_path}"
        FileUtils.cp_r path, installation_path
        Sprout::Log.puts ">> Copied files from: (#{path}) to: (#{installation_path})"
      end
      installation_path
    end

    def define_file_copy_task path, installation_path
      task_name = "#{installation_path}/#{File.basename(path)}"
      define_file_task task_name do
        FileUtils.mkdir_p installation_path
        FileUtils.cp path, "#{installation_path}/"
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
def library pkg_name, type=nil, version=nil
  Sprout::Library.define_task pkg_name, type, version
end

