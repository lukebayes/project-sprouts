
module Sprout
  
  class ToolTaskError < StandardError #:nodoc:
  end
  
  # The ToolTask provides some base functionality for any Command Line Interface (CLI) tool. 
  # It also provides support for GUI tools that you would like to expose from the
  # Command Line (Like the Flash Player for example).
  #
  # ToolTask extends Rake::FileTask, and should be thought of in the same way. 
  # Martin Fowler did a much better job of describing Rake and specifically FileTasks than 
  # I can in his (now classic) Rake article[http://martinfowler.com/articles/rake.html#FileTasks] from 2005.
  #
  # What this means is that most tool task instances should be named for the file that they will create.
  # For example, an Sprout::MXMLCTask instance should be named for the SWF that it will generate.
  #
  #   mxmlc 'bin/SomeProject.swf' => :corelib do |t|
  #     t.input                     = 'src/SomeProject.as'
  #     t.default_size              = '800 600'
  #   end
  #
  # In general, a tool task will only be executed if it's output file (name) does not exist or
  # if the output file is older than any file identified as a prerequisite.
  #
  # Many of the compiler tasks take advantage of this feature by opting out of unnecessary compilation.
  #
  # Subclasses can add and configure command line parameters by calling the protected add_param method
  # that is implemented on this class.
  #
  class ToolTask < Rake::FileTask
    
    # Arguments to be prepended in front of the command line output
    attr_accessor :prepended_args
    # Arguments to appended at the end of the command line output
    attr_accessor :appended_args        
    # Command line arguments to execute preprocessor.
    # The preprocessor execution should accept via STDIN and return through STDOUT.
    # For example:
    #
    #   mxmlc 'bin/SomeProject.swf' => :corelib do |t|
    #     t.input                     = 'src/SomeProject.as'
    #     t.default_size              = '800 600'
    #     t.preprocessor              = 'cpp -DDEBUG -P - -'
    #   end
    #
    attr_accessor :preprocessor
    # Path where preprocessed files are stored
    attr_accessor :preprocessed_path
    
    def initialize(name, app) # :nodoc:
      super
      @prepended_args   = nil
      @appended_args    = nil
      @default_gem_name = nil
      @default_gem_path = nil
      initialize_task
    end
    
    def self.define_task(args, &block)
      t = super
      if(t.is_a?(ToolTask))
        yield t if block_given?
        t.define
        t.prepare
      end
      return t
    end
    
    # Full name of the sprout tool gem that this tool task will use. For example, the MXMLCTask
    # uses the sprout-flex3sdk-tool at the time of this writing, but will at some point 
    # change to use the sprout-flex3sdk-tool. You can combine this value with gem_version
    # in order to specify exactly which gem your tool task is executing.
    def gem_name
      return @gem_name ||= @default_gem_name
    end
    
    def gem_name=(name)
      @gem_name = name
    end

    # The exact gem version that you would like the ToolTask to execute. By default this value
    # should be nil and will download the latest version of the gem that is available unless
    # there is a version already installed on your system. 
    # 
    # This attribute could be an easy
    # way to update your local gem to the latest version without leaving your build file,
    # but it's primary purpose is to allow you to specify very specific versions of the tools
    # that your project depends on. This way your team can rest assured that they are all
    # working with the same tools.
    def gem_version
      return @gem_version ||= nil
    end
    
    def gem_version=(version)
      @gem_version = version
    end
    
    # The path inside the installed gem where an executable can be found. For the MXMLCTask, this
    # value is 'bin/mxmlc'.
    def gem_path
      return @gem_path ||= @default_gem_path
    end
    
    # Create a string that can be turned into a file
    # that rdoc can parse to describe the customized
    # or generated task using param name, type and
    # description
    def to_rdoc
      result = ''
      parts = self.class.to_s.split('::')
      class_name = parts.pop
      module_count = 0
      while(module_name = parts.shift)
        result << "module #{module_name}\n"
        module_count += 1
      end
      
      result << "class #{class_name} < ToolTask\n"

      params.each do |param|
        result << param.to_rdoc
      end

      while((module_count -= 1) >= 0)
        result << "end\nend\n"
      end

      return result
    end
    
    def execute(*args)
      #puts ">> Executing #{File.basename(exe)} #{to_shell}"
      exe = Sprout.get_executable(gem_name, gem_path, gem_version)
      User.execute(exe, to_shell)
    end
    
    # Create a string that represents this configured tool for shell execution
    def to_shell
      result = []
      result << @prepended_args unless @prepended_args.nil?
      params.each do |param|
        if(param.visible?)
          result << param.to_shell
        end
      end
      result << @appended_args unless @appended_args.nil?
      return result.join(' ')
    end

    # An Array of all parameters that have been added to this Tool.
    def params
      @params ||= []
    end
    
    # Called after initialize and define, usually subclasses should
    # only override define.
    def prepare
      # Get each added param to inject prerequisites as necessary
      params.each do |param|
        param.prepare
      end
      # Ensure there are no duplicates in the prerequisite collection
      @prerequisites = prerequisites.uniq
    end

    def define
      resolve_libraries(prerequisites)
    end
    
    # The default file expression to append to each PathParam
    # in order to build file change prerequisites.
    # 
    # Defaults to '/**/**/*'
    #
    def default_file_expression
      @default_file_expression ||= '/**/**/*'
    end
    
    protected 
    
    def initialize_task
    end

    def validate
      params.each do |param|
        param.validate
      end
    end

    # +add_param+ is the workhorse of the ToolTask.
    # This method is used to add new shell parameters to the task.
    # +name+ is a symbol or string that represents the parameter that you would like to add
    # such as :debug or :source_path.
    # +type+ is usually sent as a Ruby symbol and can be one of the following:
    #
    # [:string]   Any string value
    # [:boolean]  true or false
    # [:number]   Any number
    # [:file]     Path to a file
    # [:url]      Basic URL
    # [:path]     Path to a directory
    # [:files]    Collection of files
    # [:paths]    Collection of directories
    # [:strings]  Collection of arbitrary strings
    # [:urls]     Collection of URLs
    #
    # Be sure to check out the Sprout::TaskParam class to learn more about
    # block editing the parameters.
    #
    # Once parameters have been added using the +add_param+ method, clients
    # can set and get those parameters from the newly created task.
    #
    def add_param(name, type, &block) # :yields: Sprout::TaskParam
      name = name.to_s

      # First ensure the named accessor doesn't yet exist...
      if(param_hash[name])
        raise ToolTaskError.new("TaskBase.add_param called with existing parameter name: #{name}")
      end

      param = create_param(type)
      param.init do |p|
        p.belongs_to = self
        p.name = name
        p.type = type
        yield p if block_given?
      end

      param_hash[name] = param
      params << param
    end

    # Alias an existing parameter with another name. For example, the 
    # existing parameter :source_path might be given an alias '-sp' as follows:
    #
    #   add_param_alias(:sp, :source_path)
    #
    # Alias parameters cannot be configured differently from the parameter
    # that they alias
    #
    def add_param_alias(name, other_param)
      if(param_hash.has_key? other_param.to_s)
        param_hash[name.to_s] = param_hash[other_param.to_s]
      else
        raise ToolTaskError.new("TaskBase.add_param_alis called with")
      end
    end

    protected

    def create_param(type)
      return eval("#{type.to_s.capitalize}Param.new")
    end
    
    def param_hash
      @param_hash ||= {}
    end

    def respond_to?(name)
      result = super
      if(!result)
        result = param_hash.has_key? name
      end
      return result
    end

    def clean_name(name)
      name.gsub(/=$/, '')
    end

    def method_missing(name,*args)
      name = name.to_s
      cleaned = clean_name(name)
      if(!respond_to?(cleaned))
        raise NoMethodError.new("undefined method '#{name}' for #{self.class}")
      end
      param = param_hash[cleaned]

      if(name =~ /=$/)
        param.value = args.shift
      elsif(param)
        param.value
      else
        raise ToolTaskError.new("method_missing called with undefined parameter [#{name}]")
      end
    end

    # Iterate over all prerequisites looking for any
    # that are a LibraryTask.
    # Concrete ToolTask implementations should
    # override resolve_library in order to add
    # the library sources or binaries appropriately.
    def resolve_libraries(prerequisites)
      prerequisites.each do |prereq|
        instance = Rake::application[prereq]
        if(instance.is_a?(LibraryTask))
          resolve_library(instance)
        end
      end
    end
    
    # Concrete ToolTasks should override this method
    # and add any dependent libraries appropriately
    def resolve_library(library_task)
    end
    
    # If the provided path contains spaces, wrap it in quotes so that
    # shell tools won't choke on the spaces
    def clean_path(path)
      if(path.index(' '))
        path = %{"#{path}"}
      end
      return path
    end
    
  end

  #######################################################
  # Parameter Implementations
  
  # The base class for all ToolTask parameters. This class is extended by a variety
  # of concrete implementations.
  #
  # At the time of this writing, only the :boolean TaskParam modifies the interface by
  # adding the +show_on_false+ attribute.
  #
  # Some other helpful features are as follows:
  #
  # :file, :files, :path and :paths will all add any items that have been added to
  # their values as file task prerequisites. This is especially helpful when writing
  # rake tasks for Command Line Interface (CLI) compilers.
  #
  class TaskParam
    attr_accessor :belongs_to
    attr_accessor :description
    attr_accessor :hidden_name
    attr_accessor :hidden_value
    attr_accessor :name
    attr_accessor :preprocessable
    attr_accessor :required
    attr_accessor :type
    attr_accessor :validator
    attr_accessor :visible

    attr_writer   :prefix
    attr_writer   :value
    attr_writer   :delimiter
    attr_writer   :shell_name

    # Set the file_expression (blob) to append to each path
    # in order to build the prerequisites FileList.
    #
    # Defaults to parent ToolTask.default_file_expression
    attr_writer :file_expression

    def init
      yield self if block_given?
    end
    
    # By default, ToolParams only appear in the shell
    # output when they are not nil
    def visible?
      @visible ||= value
    end
    
    def required?
      (required == true)
    end
    
    def validate
      if(required? && !visible?)
        raise ToolTaskError.new("#{name} is required and must not be nil")
      end
    end
    
    def prepare
      prepare_prerequisites
    end
    
    def prepare_prerequisites
    end
    
    # Should the param name be hidden from the shell?
    # Used for params like 'input' on mxmlc
    def hidden_name?
      @hidden_name ||= false
    end
    
    # Should the param value be hidden from the shell?
    # Usually used for Boolean toggles like '-debug'
    def hidden_value?
      @hidden_value ||= false
    end
    
    # Leading character for each parameter
    # Can sometimes be an empty string,
    # other times it's a double dash '--'
    # but usually it's just a single dash '-'
    def prefix
      @prefix ||= '-'
    end
    
    def value
      @value ||= nil
    end

    def shell_value
      value.to_s
    end

    def file_expression # :nodoc:
      @file_expression ||= belongs_to.default_file_expression
    end

    # ToolParams join their name/value pair with an
    # equals sign by default, this can be modified 
    # To a space or whatever you wish
    def delimiter
      @delimiter ||= '='
    end
    
    # Return the name with a single leading dash
    # and underscores replaced with dashes
    def shell_name
      @shell_name ||= prefix + name.split('_').join('-')
    end

    def to_shell
      if(hidden_name?)
        return shell_value
      elsif(hidden_value?)
        return shell_name
      else
        return "#{shell_name}#{delimiter}#{shell_value}"
      end
    end
    
    # Create a string that can be turned into a file
    # that rdoc can parse to describe the customized
    # or generated task using param name, type and
    # description
    def to_rdoc
      result = ''
      parts = description.split("\n") unless description.nil?
      result << "# #{parts.join("\n# ")}\n" unless description.nil?
      result << "def #{name}=(#{type})\n  @#{name} = #{type}\nend\n\n"
      return result
    end

    protected
    
    def should_preprocess?
      return preprocessable && !belongs_to.preprocessor.nil?
    end
    
    def prepare_preprocessor_paths(paths)
      processed = []
      paths.each do |path|
        processed << prepare_preprocessor_path(path)
      end
      return processed
    end
    
    def prepare_preprocessor_files(files)
      processed = []
      files.each do |file|
        processed << prepare_preprocessor_file(file)
      end
      return processed
    end
    
    def prepare_preprocessor_path(path)
      files = FileList[path + file_expression]
      files.each do |input_file|
        prepare_preprocessor_file(input_file)
      end
      
      return File.join(belongs_to.preprocessed_path, path)
    end
    
    def prepare_preprocessor_file(input_file)
      output_file = File.join(belongs_to.preprocessed_path, input_file)
      setup_preprocessing_file_tasks(input_file, output_file)
      return output_file
    end
    
    def setup_preprocessing_file_tasks(input_file, output_file)
      file input_file
      file output_file => input_file do |pending_file|
        pending = pending_file.name
        FileUtils.mkdir_p(File.dirname(pending))
        if(!File.directory?(pending))
          File.open(input_file, 'r') do |readable|
            File.open(output_file, 'w+') do |writable|
              preprocess_content(readable, writable, belongs_to.preprocessor)
            end
          end
        end
      end
      belongs_to.prerequisites << output_file
    end
    
    def preprocess_content(readable, writable, processor)
      process = ProcessRunner.new(processor)
      process.puts(readable.read)
      process.close_write
      writable.write(process.read)
    end
    
  end

  # Concrete param object for :string values
  class StringParam < TaskParam # :nodoc:
    
  end

  # Concrete param object for :symbol values
  # like class names
  class SymbolParam < TaskParam # :nodoc:
  end

  # Concrete param object for :url values
  class UrlParam < TaskParam # :nodoc:
  end

  # Concrete param object for :number values
  class NumberParam < TaskParam # :nodoc:
  end

  # Concrete param object for :file values
  class FileParam < TaskParam # :nodoc:

    def prepare_prerequisites
      if(value && value != belongs_to.name.to_s)
        if(should_preprocess?)
          @value = prepare_preprocessor_file(value)
        else
          file value
          belongs_to.prerequisites << value
        end
      end
    end
  end

  # Concrete param object for :path values
  class PathParam < TaskParam # :nodoc:

    def prepare_prerequisites
      if(value && value != belongs_to.name.to_s)
        if should_preprocess?
          @value = prepare_preprocessor_path(value)
        else
          file value
          belongs_to.prerequisites << value
        end
      end
    end
  end

  # Concrete param object for :boolean values
  class BooleanParam < TaskParam # :nodoc:
    attr_writer :show_on_false
    
    def visible?
      @visible ||= value
      if(show_on_false)
        return true unless value
      else
        return @visible
      end
    end

    def show_on_false
      @show_on_false ||= false
    end
    
    def value
      @value ||= false
    end

  end

  # Concrete param object for collections of strings
  class StringsParam < TaskParam # :nodoc:

    # Files lists are initialized to an empty array by default
    def value
      @value ||= []
    end

    # By default, the FilesParams will not appear in the shell
    # output if there are zero items in the collection
    def visible?
      @visible ||= (value && value.size > 0)   
    end

    # Default delimiter is +=
    # This is what will appear between each name/value pair as in:
    # "source_path+=src source_path+=test source_path+=lib"
    def delimiter
      @delimiter ||= "+="
    end
    
    # Returns a shell formatted string of the collection
    def to_shell
      result = []
      value.each do |str|
        result << "#{shell_name}#{delimiter}#{str}"
      end
      return result.join(' ')
    end
  end

  # Concrete param object for collections of symbols (like class names)
  class SymbolsParam < StringsParam # :nodoc:
  end

  # Concrete param object for collections of files
  class FilesParam < StringsParam # :nodoc:

    def prepare
      super
      usr = User.new
      path = nil
      value.each_index do |index|
        path = value[index]
        value[index] = usr.clean_path path
      end
    end

    def prepare_prerequisites
      if should_preprocess?
        @value = prepare_preprocessor_files(value)
      else
        value.each do |f|
          file f
          belongs_to.prerequisites << f
        end
      end
    end

  end

  # Concrete param object for collections of paths
  class PathsParam < FilesParam # :nodoc:

    def prepare_prerequisites
      if should_preprocess?
        @value = prepare_preprocessor_paths(value)
      else
        value.each do |path|
          files = FileList[path + file_expression]
          files.each do |f|
            file f
            belongs_to.prerequisites << f
          end
        end
      end
    end
    

  end

  # Concrete param object for collections of files
  class UrlsParam < StringsParam # :nodoc:
  end

end
