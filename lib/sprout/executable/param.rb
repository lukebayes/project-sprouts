
module Sprout

  module Executable

    ##
    # The abstract base class for all Executable parameters.
    #
    # This class provides a variety of template methods and general
    # functionality to the different executable parameter types.
    #
    # Many of these parameter attributes are exposed to Sprout::Executable
    # concrete classes as the options hash like:
    #
    #   class Foo
    #     include Sprout::Executable
    #
    #     add_param :name, String, :hidden_name => true
    #   end
    #
    # @see Sprout::Executable::Boolean
    # @see Sprout::Executable::FileParam
    # @see Sprout::Executable::Files
    # @see Sprout::Executable::Number
    # @see Sprout::Executable::ParameterFactory
    # @see Sprout::Executable::Path
    # @see Sprout::Executable::Paths
    # @see Sprout::Executable::StringParam
    # @see Sprout::Executable::Strings
    # @see Sprout::Executable::Url
    # @see Sprout::Executable::Urls
    #
    class Param

      ##
      # Default value for the delimiter that will
      # separate parameter names from their values.
      DEFAULT_DELIMITER               = '='

      ##
      # Defaut TYPE assumed for parameters when
      # creating documentation for the OptionParser.
      DEFAULT_OPTION_PARSER_TYPE_NAME = 'STRING'

      ##
      # Default value for the parameter prefix.
      # Should usually be pulled from the 
      # +belongs_to+ Sprout::Executable.
      DEFAULT_PREFIX                  = '--'

      ## 
      # Default prefix for truncated parameters.
      # Should usually be pulled from the 
      # +belongs_to+ Sprout::Executable.
      DEFAULT_SHORT_PREFIX            = '-'

      ##
      # The Sprout::Executable that this parameter
      # instance belongs to.
      attr_accessor :belongs_to

      ##
      # Executable::Params join their name/value pair with an
      # equals sign by default, this can be modified 
      # To a space or whatever you wish.
      attr_accessor :delimiter

      ##
      # The String description that will be used for
      # RDoc documentation and user help.
      attr_accessor :description

      ##
      # Boolean value that hides the name parameter
      # from the shell execution.
      #
      #    add_param :name, String, :hidden_name => true
      #
      # Without this option, the above parameter would 
      # serialize to the process like:
      #
      #   foo --name=Value
      #
      # But with this option, the above parameter would
      # serialize to the process like:
      #
      #   foo Value
      #
      attr_accessor :hidden_name

      ##
      # Boolean value that hides the value parameter
      # from the shell execution.
      #
      #   add_param :visible, Boolean, :hidden_value => true
      #
      # Without this option, the above parameter would
      # serialize to the process like:
      #
      #   foo --visible=true
      #
      # But with this option, the above parameter would
      # serialize to the process like:
      #
      #   foo --visible
      #
      attr_accessor :hidden_value

      ##
      # The String (or Symbol) name of the parameter.
      attr_accessor :name

      ##
      # The String prefix that should be in front of each
      # command line parameter.
      #
      # If no value is set for this option, the 
      # DEFAULT_PREFIX (--) will be used for regular parameters,
      # and the DEFAULT_SHORT_PREFIX (-) will be used for short
      # parameters.
      attr_accessor :prefix

      ##
      # A Symbol that refers to a custom attribute reader
      # that is available to instance methods on the 
      # Sprout::Executable that uses it.
      #
      #   add_param :visible, Boolean, :reader => :get_visible
      #
      #   def get_visible
      #     return @visible
      #   end
      #
      attr_accessor :reader

      ##
      # Boolean value that will cause a Sprout::Errors::UsageError
      # if the executable is invoked without this parameter first
      # being set.
      #
      #   add_param :visible, Boolean :required => true
      #
      # Default false
      #
      attr_accessor :required

      ##
      # An optional Proc that should be called when this parameter
      # is serialized to shell output. The Proc should return a 
      # String value that makes sense to the underlying process.
      #
      #   add_param :visible, Boolean, :to_shell_proc => Proc.new {|p| "---result" }
      #
      attr_accessor :to_shell_proc

      ##
      # The data type of the parameter, used to generate more appropriate
      # RDoc content for the concrete Sprout::Executable.
      attr_accessor :type
      
      ##
      # The value that was assigned to this parameter when the 
      # concrete Sprout::Executable was instantiated and configured.
      attr_accessor :value

      ##
      # A Symbol that refers to a custom attribute writer
      # that is available to instance methods on the 
      # Sprout::Executable that uses it.
      #
      #   add_param :visible, Boolean, :writer => :set_visible
      #
      #   def set_visible=(vis)
      #     @visible = vis
      #   end
      #
      attr_accessor :writer

      ##
      # Set the file_expression (blob) to append to each path
      # in order to build the prerequisites FileList.
      #
      # Defaults to the parent Executable.default_file_expression
      #
      # TODO: We should add support for file_expressionS
      # since these are really just blobs that are sent
      # to the FileList[expr] and that interface accepts
      # an array.
      attr_writer :file_expression

      ##
      # Optional String value of the name of this parameter
      # that should be returned to the shell.
      #
      # By default, this method will infer the name by
      # prepending the +prefix+ and replacing underscores
      # with dashes. For example:
      #
      #   add_param :some_name, String
      #
      # Would return '--some-name=value' to the shell.
      #
      # If this option is set, then the provided value
      # will be used rather than inferred.
      #
      #   add_param :some_name, String, :shell_name => '--OtherName'
      #
      # Would return '--OtherName=value' when sent to the shell.
      #
      attr_writer :shell_name

      ##
      # Optional String value that should be used for this
      # parameter's short name. Generally only helpful
      # for Sprout::Executable 's that are going to be exposed
      # to Ruby OptionParser as Ruby applications.
      #
      # By default, this value will be the first letter
      # of the parameter name, and when multiple parameters
      # share the same first letter, the first one encountered
      # will be used.
      attr_writer :short_name
      ##
      # Default constructor for Params, if you create
      # a new concrete type, be sure to call +super()+ in your
      # own constructor.
      def initialize
        @description             = 'Default Description'
        @hidden_value            = false
        @hidden_name             = false
        @delimiter               = DEFAULT_DELIMITER
        @option_parser_type_name = DEFAULT_OPTION_PARSER_TYPE_NAME
      end

      ##
      # By default, Executable::Params only appear in the shell
      # output when they are not nil
      def visible?
        !value.nil?
      end
      
      ##
      # Returns Boolean value if this parameter is required.
      def required?
        (required == true)
      end
      
      ##
      # Ensure this parameter is in a valid state, raise a Sprout::Errors::MissingArgumentError
      # if it is not.
      def validate
        if(required? && value.nil?)
          raise Sprout::Errors::MissingArgumentError.new("#{name} is required and must not be nil")
        end
      end

      ##
      # Set the default value of the parameter.
      # Using this option will ensure that required parameters
      # are not nil, and default values can be overridden on 
      # instances.
      #
      #   add_param :name, String, :default => 'Bob'
      #
      def default=(value)
        self.value = value
        @default = value
      end

      ##
      # Return the default value or nil if none was provided.
      def default
        @default
      end
      
      ##
      # Prepare the parameter for execution or delegation, depending
      # on what context we're in.
      def prepare
        prepare_prerequisites
        @prepared = true
      end

      ##
      # Returns true if this parameter has already been prepared.
      def prepared?
        @prepared
      end
      
      ##
      # Should the param name be hidden from the shell?
      # Used for params like 'input' on mxmlc
      def hidden_name?
        @hidden_name
      end
      
      ##
      # Should the param value be hidden from the shell?
      # Usually used for Boolean toggles like '-debug'
      def hidden_value?
        @hidden_value
      end
      
      ##
      # Leading character for each parameter
      # Can sometimes be an empty string,
      # other times it's a double dash '--'
      # but usually it's just a single dash '-'
      def prefix
        @prefix ||= (belongs_to.nil?) ? DEFAULT_PREFIX : belongs_to.default_prefix
      end

      def short_prefix
        @short_prefix ||= (belongs_to.nil?) ? DEFAULT_SHORT_PREFIX : belongs_to.default_short_prefix
      end

      ##
      # How this parameter is provided to the
      # Ruby OptionParser when being exposed as a Ruby Executable.
      def option_parser_declaration
        declaration = default_option_parser_declaration
        # TODO: Need to figure out how to support hidden name inputs...
        #if(hidden_name?)
          #declaration = [option_parser_type_output]
        #
        if(!hidden_value?)
          declaration << delimiter << option_parser_type_output
        end
        declaration.join('')
      end

      def default_option_parser_declaration
        [ prefix, option_parser_name ]
      end

      ##
      # The Ruby OptionParser short name with prefix.
      def option_parser_short_name
        [ short_prefix, short_name ].join('')
      end
      
      ##
      # The short name for this parameter.
      # If it's not explicitly, the first
      # character of the parameter name will
      # be used. When multiple parameters have
      # the same first character, the first one
      # encountered will win.
      def short_name
        @short_name ||= name.to_s.split('').shift
      end

      ##
      # The String representation of the value in
      # a format that is appropriate for the terminal.
      #
      # For certain types of parameters, like File,
      # spaces may be escaped on some platforms.
      #
      def shell_value
        value.to_s
      end

      def file_expression
        @file_expression ||= belongs_to.default_file_expression
      end

      def shell_name
        @shell_name ||= prefix + name.to_s.split('_').join('-')
      end

      ##
      # Prepare and serialize this parameter to a string
      # that is appropriate for shell execution on the
      # current platform.
      #
      # Calling +to_shell+ will first trigger a call to
      # the +prepare+ template method unless +prepared?+ returns +true+.
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

      def option_parser_name
        name.to_s.gsub('_', '-')
      end

      def option_parser_type_name
        @option_parser_type_name
      end

      def option_parser_type_output
        type = hidden_value? ? '' : option_parser_type_name
        required? ? type : "[#{type}]"
      end

      def prepare_prerequisites
      end

      ##
      # Clean the provided path using the current Sprout::System.
      def clean_path path
        Sprout::System.create.clean_path path
      end

      ##
      # Return true if the Sprout::Executable
      # that this parameter +belongs_to+ has an +output+
      # method (or parameter), and if the provided +file+
      # matches the value of that parameter.
      #
      # This method (convention) is used to avoid creating circular
      # prerequisites in Rake. For most types of File parameters
      # we want to make them into prerequisites, but not if the
      # File is the one being created by the outer Sprout::Executable.
      def file_is_output? file
        belongs_to.respond_to?(:output) && belongs_to.output.to_s == file
      end

    end
  end
end

