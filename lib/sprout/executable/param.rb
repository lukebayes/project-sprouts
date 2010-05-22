
module Sprout

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
  # Executable::Params have a template method lifecycle that one should become
  # familiar with before working with them directly.
  #
  # Depending on what you may do in subclasses, the lifecycle methods 
  # should be called in the following order:
  # 
  # # initialize
  # 
  # # prepare
  #
  # # prepare_prerequisites
  #
  # # validate
  #
  # # visible?
  #
  # # to_shell
  # 

  module Executable
    class Param
      attr_accessor :belongs_to
      attr_accessor :description
      attr_accessor :hidden_name
      attr_accessor :hidden_value
      attr_accessor :name
      attr_accessor :prefix

      ##
      # This parameter value can or should be handed to any declared preprocessor.
      #
      # Generally, this parameter is set to true for files and paths.
      #
      attr_accessor :preprocessable
      attr_accessor :required
      attr_accessor :to_shell_proc
      attr_accessor :type
      attr_accessor :validator
      attr_accessor :value
      attr_accessor :visible

      # Executable::Params join their name/value pair with an
      # equals sign by default, this can be modified 
      # To a space or whatever you wish
      # Return the name with a single leading dash
      # and underscores replaced with dashes
      attr_accessor   :delimiter

      # Set the file_expression (blob) to append to each path
      # in order to build the prerequisites FileList.
      #
      # Defaults to parent Executable.default_file_expression
      #
      # NOTE: We should add support for file_expressionS
      # since these are really just blobs that are sent
      # to the FileList[expr] and that interface accepts
      # an array.
      attr_writer :file_expression

      attr_writer :shell_name

      def initialize
        @prefix = '-'
        @delimiter = '='
      end

      # By default, Executable::Params only appear in the shell
      # output when they are not nil
      def visible?
        !value.nil?
      end
      
      def required?
        (required == true)
      end
      
      def validate
        if(required? && value.nil?)
          raise Sprout::Errors::MissingArgumentError.new("#{name} is required and must not be nil")
        end
      end

      def default=(value)
        self.value = value
        @default = value
      end

      def default
        @default
      end
      
      def prepare
        prepare_prerequisites
        @prepared = true
      end

      def prepared?
        @prepared
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
      
      def option_parser_name
        "--#{name.to_s.gsub('_', '-')}"
      end

      def option_parser_type_name
        'STRING'
      end

      def option_parser_type_output
        type = hidden_value? ? '' : option_parser_type_name
        required? ? type : "[#{type}]"
      end

      def short_name
        "-#{name.to_s.split('').shift}"
      end

      def description
        "Generic Description"
      end

      def shell_value
        value.to_s
      end

      def file_expression
        @file_expression ||= belongs_to.default_file_expression
      end

      def shell_name
        @shell_name ||= prefix + name.to_s.split('_').join('-')
      end

      def to_shell
        prepare if !prepared?
        validate
        return '' if !visible?
        return @to_shell_proc.call(self) unless @to_shell_proc.nil?
        return shell_value if hidden_name?
        return shell_name if hidden_value?
        return [shell_name, delimiter, shell_value].join
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

      def clean_path path
        Sprout::System.create.clean_path path
      end
      
      def should_preprocess?
        false
      end
      
=begin

      # This is the preprocessor implementation from Sprout 0.7
      # We need to make time to refactor this into a new / separate 
      # set of modules or find some way to extract it from here and test it.

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
      
      def cleaned_preprocessed_path(path)
        File.join(belongs_to.preprocessed_path, path.gsub('../', 'backslash/'))
      end
      
      def prepare_preprocessor_path(path)
        processed_path = cleaned_preprocessed_path(path)
        FileUtils.mkdir_p(processed_path)
        files = FileList[path + file_expression]
        files.each do |input_file|
          prepare_preprocessor_file(input_file)
        end
        
        return processed_path
      end
      
      def prepare_preprocessor_file(input_file)
        output_file = cleaned_preprocessed_path(input_file)
        setup_preprocessing_file_tasks(input_file, output_file)
        return output_file
      end
      
      def text_file?(file_name)
        [/\.as$/, /\.txt$/, /\.mxml$/, /\.xml$/, /\.js$/, /\.html$/, /\.htm$/].select do |regex|
          if (file_name.match(regex))
            return true
          end
        end.size > 0
      end
      
      def setup_preprocessing_file_tasks(input_file, output_file)
        return if(File.directory?(input_file))
        CLEAN.add(belongs_to.preprocessed_path) if(!CLEAN.index(belongs_to.preprocessed_path))
        
        # Only create the preprocessed action if one does not
        # already exist. There were many being created before...
          
        file input_file
        file output_file => input_file do
          # Couldn't return, b/c Rake complained...
          if(!ToolTask::has_preprocessed_task?(output_file))
            dir = File.dirname(output_file)
            if(!File.exists?(dir))
              FileUtils.mkdir_p(dir)
            end
          
            content = nil
            # Open the input file and read its content:
            File.open(input_file, 'r') do |readable|
              content = readable.read
            end
          
            # Preprocess the content if it's a known text file type:
            if(text_file?(input_file))
              content = preprocess_content(content, belongs_to.preprocessor, input_file)
            end
          
            # Write the content to the output file:
            File.open(output_file, 'w+') do |writable|
              writable.write(content)
            end

            # COMMENTED on: Sunday, May 2nd 2010:
            # TODO: need to figure out preprocessing again:
            #ToolTask::add_preprocessed_task(output_file)
          end
        end
        
        belongs_to.prerequisites << output_file
      end
      
      def preprocess_content(content, statement, file_name)
        process = ProcessRunner.new(statement)
        process.puts(content)
        process.close_write
        result = process.read
        error = process.read_err
        if(error.size > 0)
          belongs_to.display_preprocess_message
          FileUtils.rm_rf(belongs_to.preprocessed_path)
          raise Sprout::Errors::ExecutionError.new("[ERROR] Preprocessor failed on file #{file_name} #{error}")
        end
        process.kill
        Log.puts ">> Preprocessed and created: #{belongs_to.preprocessed_path}/#{file_name}"
        return result
      end
=end

    end
  end
end

