
module Sprout

  module Executable

    ##
    # The abstract base class for all Executable parameters.
    #
    class Param
      DEFAULT_DELIMITER               = '='
      DEFAULT_OPTION_PARSER_TYPE_NAME = 'STRING'

      # These values should usually be pulled
      # from the 'belongs_to' executable:
      DEFAULT_PREFIX                  = '--'
      DEFAULT_SHORT_PREFIX            = '-'

      attr_accessor :belongs_to
      attr_accessor :description
      attr_accessor :hidden_name
      attr_accessor :hidden_value
      attr_accessor :file_task_name
      attr_accessor :name
      attr_accessor :prefix
      attr_accessor :reader
      attr_accessor :required
      attr_accessor :to_shell_proc
      attr_accessor :type
      attr_accessor :validator
      attr_accessor :value
      attr_accessor :visible
      attr_accessor :writer

      ##
      # Executable::Params join their name/value pair with an
      # equals sign by default, this can be modified 
      # To a space or whatever you wish.
      attr_accessor :delimiter

      ##
      # Set the file_expression (blob) to append to each path
      # in order to build the prerequisites FileList.
      #
      # Defaults to the parent Executable.default_file_expression
      #
      # NOTE: We should add support for file_expressionS
      # since these are really just blobs that are sent
      # to the FileList[expr] and that interface accepts
      # an array.
      attr_writer :file_expression

      ##
      # Return the name with a single leading dash
      # and underscores replaced with dashes
      attr_writer :shell_name

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
      # Raise an exception if a required parameter is nil.
      def required?
        (required == true)
      end
      
      ##
      # Ensure this parameter is in a valid state, raise an appropriate
      # exception if it is not.
      def validate
        if(required? && value.nil?)
          raise Sprout::Errors::MissingArgumentError.new("#{name} is required and must not be nil")
        end
      end

      ##
      # Set the default value of the parameter.
      def default=(value)
        self.value = value
        @default = value
      end

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

      def option_parser_declaration
        declaration = [ prefix, option_parser_name ]
        # TODO: Need to figure out how to support hidden name inputs...
        #if(hidden_name?)
          #declaration = [option_parser_type_output]
        #
        if(!hidden_value?)
          declaration << delimiter << option_parser_type_output
        end
        declaration.join('')
      end

      def option_parser_short_name
        [ short_prefix, short_name ].join('')
      end
      
      def short_name
        @short_name ||= name.to_s.split('').shift
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

      def clean_path path
        Sprout::System.create.clean_path path
      end

      def file_is_output? file
        belongs_to.respond_to?(:output) && belongs_to.output.to_s == file
      end

    end
  end
end

