
module Sprout
  # The ProjectModel gives you a place to describe your project so that you
  # don't need to repeat yourself throughout a rakefile.
  #
  # The default set of properties are also used from code generators, library tasks and sometimes tools.
  #
  # The ProjectModel can be configured as follows:
  #   project_model :model do |p|
  #     p.name          = 'SomeProject'
  #     p.source_path   << 'somedir/otherdir'
  #     p.library_path  << 'somedir'
  #   end
  #
  # This class should have some reasonable default values, but can be modified from any rakefile.
  # If you don't find some properties that you'd like on the ProjectModel, you can simply add 
  # new properties and use them however you wish. 
  #
  # Arbitrary properties can be added as follows:
  #   m = project_model :model do |p|
  #     p.unknown_property = 'someValue'
  #   end
  # 
  #   puts "Unknown Property: #{m.unknown_property}"
  #
  # The ProjectModel is typically treated as if it is a Singleton, and many helper tasks
  # will automatically go look for their model at:
  # 
  #   Sprout::ProjectModel.instance
  #
  # Unlike a real Singleton, this static property will actually be populated with the most
  # recently instantiated ProjectModel, and any well-behaved helper task will also
  # allow you to send in a model as a prerequisite.
  #
  #   project_model :model_a
  #   project_model :model_b
  #
  #   desc 'Compile and run a'
  #   debug :debug_a => :model_a
  #
  #   desc 'Compile and run b'
  #   debug :debug_b => :model_b
  #
  class ProjectModel < Hash
    
    # Relative path to the folder where compile time assets will be stored
    attr_accessor :asset_dir
    # The folder where binary files will be created. Usually this is where any build artifacts like SWF files get placed.
    attr_accessor :bin_dir
    # The Background Color of the SWF file
    attr_accessor :background_color
    # Contributors to the SWF file
    attr_accessor :contributors
    # If you don't want to use the default compiler for your language
    # set it manually here.
    # Possible values are:
    # * sprout-flex2sdk-tool
    # * sprout-flex3sdk-tool
    # * sprout-flex4sdk-tool (Experimental)
    # * sprout-mtasc-tool
    attr_accessor :compiler_gem_name
    # The version number of the compiler gem to use
    attr_accessor :compiler_gem_version
    # The primary creator of the SWF file
    attr_accessor :creator
    # Directory where documentation should be placed.
    attr_accessor :doc_dir
    # CSS documents that should be individually compiled
    # for runtime stylesheet loading.
    attr_accessor :external_css
    # The default frame rate of the SWF file
    attr_accessor :frame_rate
    # The default height of the SWF file
    # _(This value is overridden when embedded in an HTML page)_
    attr_accessor :height
    # The technology language that is being used, right now this value can be 'as2', 'as3' or 'mxml'.
    # Code generators take advantage of this setting to determine which templates to use
    # and build tasks use this setting to determin the input file suffix (.as or .mxml).
    attr_accessor :language
    # The relative path to your library directory. Defaults to 'lib'
    #
    # Any remote .SWC and source libraries that are referenced in your rakefile will be installed
    # into this directory. Source libraries will be placed in a folder that matches the library name,
    # while SWCs will be simply placed directly into the lib_dir.
    attr_accessor :lib_dir
    # Array of sprout library symbols
    attr_accessor :libraries
    # The Array of SWC paths to add to all compilation tasks
    attr_accessor :library_path
    # The locale for the SWF file
    attr_accessor :locale
    # A collection of Flex Module root source files. If this collection
    # has items added to it, the deploy task will generate a 'link_report' from
    # the main application compilation and then consume it as 'load_externs' for 
    # each module compilation.
    attr_accessor :modules
    # Organization responsible for this SWF file
    attr_accessor :organization
    # The production file that this Project will generate
    attr_accessor :output
    # The real name of the project, usually capitalized like a class name 'SomeProject'
    attr_accessor :project_name
    # The folder where compile time skins can be loaded from
    attr_accessor :skin_dir
    # The skin file that will be generated
    attr_accessor :skin_output
    # The Array of source paths to add to all compilation tasks
    # _Do not add task-specific paths (like lib/asunit) to this value_
    attr_accessor :source_path
    # The relative path to your main source directory. Defaults to 'src'
    attr_accessor :src_dir
    # Enforce strict type checking
    attr_accessor :strict
    # The relative path to the directory where swc files should be kept.
    # This value defaults to lib_dir
    attr_accessor :swc_dir
    # Relative path to the folder that contains your test cases
    attr_accessor :test_dir
    # The test executable
    attr_accessor :test_output
    # The test runner SWF height
    attr_accessor :test_height
    # The test runner SWF width
    attr_accessor :test_width
    # Tasks that can, will use the Flex Compiler SHell.
    attr_accessor :use_fcsh
    # The default width of the SWF file
    # _(This value is overridden when embedded in an HTML page)_
    attr_accessor :width

    # Static method that returns the most recently instantiated ProjectModel,
    # or instantiates one if none have been created yet.
    def self.instance
      @@instance ||= ProjectModel.new
      yield @@instance if block_given?
      return @@instance
    end
    
    # Decorates the static instance method.
    def self.setup
      @@instance ||= ProjectModel.new
      yield @@instance if block_given?
      return @@instance
    end

    def self.destroy # :nodoc:
      @@instance = nil
    end

    def initialize
      super
      @project_name   = ''
      @doc_dir        = 'doc'
      @src_dir        = 'src'
      @lib_dir        = 'lib'
      @swc_dir        = 'lib'
      @bin_dir        = 'bin'
      @test_dir       = 'test'
      @asset_dir      = 'assets'
      @skin_dir       = File.join(@asset_dir, 'skins')
      @frame_rate     = 24
      @language       = 'as3'

      @external_css   = []
      @libraries      = []
      @library_path   = []
      @modules        = []
      @source_path    = []

      @model_dir      = nil
      @view_dir       = nil
      @controller_dir = nil
      
      @test_height    = 550
      @test_width     = 900
      @@instance      = self
    end
    
    # Path to the project directory from which all other paths are created
    def project_path
      return Sprout.project_path
    end
    
    def model_dir=(dir)
      @model_dir = dir
    end
    
    # Simple MVC helper for project-wide models if your project is called 'SomeProject'
    # this will default to:
    #   SomeProject/src/someproject/models
    def model_dir
      if(@model_dir.nil?)
        @model_dir = File.join(src_dir, project_name.downcase, 'models')
      end
      return @model_dir
    end
    
    def view_dir=(dir)
      @view_dir = dir
    end

    # Simple MVC helper for project-wide views if your project is called 'SomeProject'
    # this will default to:
    #   SomeProject/src/someproject/views
    def view_dir
      if(@view_dir.nil?)
        @view_dir = File.join(src_dir, project_name.downcase, 'views')
      end
      return @view_dir
    end
    
    def controller_dir=(dir)
      @controller_dir = dir
    end

    # Simple MVC helper for project-wide views if your project is called 'SomeProject'
    # this will default to:
    #   SomeProject/src/someproject/controllers
    def controller_dir
      if(@controller_dir.nil?)
        @controller_dir = File.join(src_dir, project_name.downcase, 'controllers')
      end
      return @controller_dir
    end
    
    # Alias for project_name
    def name=(name)
      @project_name = name
    end
    
    def name
      @project_name
    end
    
    def to_s
      return "[Sprout::ProjectModel project_name=#{project_name}]"
    end
    
    protected
    
    def method_missing(method_name, *args)
      method_name = method_name.to_s
      if method_name =~ /=$/
        super if args.size > 1
        self[method_name[0...-1]] = args[0]
      else
        super unless has_key?(method_name) and args.empty?
        self[method_name]
      end
    end
  end
end

# Helper method to expose the project model as a Rake Task
def project_model(task_name)
  model = Sprout::ProjectModel.new
  yield model if block_given?

  t = task task_name

  def t.project_model=(model)
    @model = model
  end

  def t.project_model
    return @model
  end
    
  t.project_model = model
  return model
end

