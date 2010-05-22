require 'sprout/executable/param'
require 'sprout/executable/collection'
require 'sprout/executable/boolean'
require 'sprout/executable/number'
require 'sprout/executable/string_param'
require 'sprout/executable/strings'
require 'sprout/executable/file_param'
require 'sprout/executable/files'
require 'sprout/executable/path'
require 'sprout/executable/paths'
require 'sprout/executable/url'
require 'sprout/executable/urls'
require 'sprout/executable/parameter_factory'

module Sprout
  module Executable


    DEFAULT_FILE_EXPRESSION = '/**/**/*'

    extend Sprout::Concern

    module ClassMethods

      # +add_param+ is the workhorse of the Task.
      # This method is used to add new shell parameters to the executable interface.
      #
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
      # Be sure to check out the Sprout::Executable::Param class to learn more about
      # block editing the parameters.
      #
      # Once parameters have been added using the +add_param+ method, clients
      # can set and get those parameters from any newly created executable instance.
      #
      # Parameters will be sent to the commandline executable in the order they are
      # added using +add_param+.
      #
      def add_param(name, type, options=nil) # :yields: Sprout::Executable::Param
        raise Sprout::Errors::UsageError.new("[DEPRECATED] add_param no longer uses closures, you can provide the same values as a hash in the optional last argument.") if block_given?
        raise Sprout::Errors::UsageError.new "The first parameter (name:SymbolOrString) is required" if name.nil?
        raise Sprout::Errors::UsageError.new "The second parameter (type:Class) is required" if type.nil?
        raise Sprout::Errors::UsageError.new "The type parameter must be a Class by reference" if !type.is_a?(Class)

        options ||= {}
        options[:name] = name
        options[:type] = type

        create_param_accessors name
        static_parameter_collection << options
        options
      end
      
      def add_param_alias new_name, old_name
        create_param_accessors new_name, old_name
      end

      def static_parameter_collection
        @static_parameter_collection ||= []
      end

      def static_default_value_collection
        @static_default_value_collection ||= {}
      end

      def set name, value
        set_default_value name, value
      end

      private

      def accessor_can_be_defined_at name
        if(instance_defines? name)
          raise Sprout::Errors::DuplicateMemberError.new("add_param called with a name that is already in use (#{name}=) on (#{self.class})")
        end
      end

      def create_param_accessors name, real_name=nil
        real_name ||= name
        accessor_can_be_defined_at name

        # define the setter:
        define_method("#{name}=") do |value|
          param_hash[real_name].value = value
        end

        # define the getter:
        define_method(name) do     
          param_hash[real_name].value
        end
      end

      def instance_defines? name
        self.instance_methods.include? name
      end

      def set_default_value name, value
        if(!instance_defines? name)
          raise Sprout::Errors::UsageError.new("Cannot set default value (#{value}) for unknown parameter (#{name})")
        end
        static_default_value_collection[name] = value
      end

    end

    module InstanceMethods

      attr_reader :param_hash
      attr_reader :params
      attr_reader :name
      # attr_reader :preprocessor
      attr_reader :prerequisites

      def initialize
        super
        @appended_args  = nil
        @prepended_args = nil
        # @preprocessed_path = nil
        @param_hash     = {}
        @params         = []
        @prerequisites  = []
        @option_parser  = OptionParser.new
        initialize_parameters
        initialize_defaults
      end

      def parse commandline_options
        option_parser.parse commandline_options
        validate
      end

      ##
      # Called from enclosing Rake::Task after
      # initialization and before any tasks are
      # executed.
      #
      # It is within this function that we can
      # define other, new Tasks and/or manipulate
      # our prerequisites.
      #
      def define
      end

      ##
      # Execute the feature after calling parse
      # with commandline arguments.
      def execute
      end

      ##
      # Call the provided executable delegate.
      #
      # This method is most often used from Rake task wrappers.
      #
      def execute_delegate
        exe = Sprout.load_executable executable, pkg_name, pkg_version
        Sprout.current_system.execute exe
      end

      # Create a string that represents this configured executable for shell execution
      def to_shell
        return @to_shell_proc.call(self) if(!@to_shell_proc.nil?)

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

      ##
      # Called by Parameters like :path and :paths
      #
      def default_file_expression
        @default_file_expression ||= Sprout::Executable::DEFAULT_FILE_EXPRESSION
      end

      ##
      # The default RubyGem that we will use when requesting our executable.
      #
      # Classes that include the Executable can set the default value for this property
      # at the class level with:
      #
      #     set :pkg_name, 'sprout-sometoolname'
      #
      # But that value can be overridden on each instance like:
      #
      #     executable = SomeToolTask.new
      #     executable.pkg_name = 'sprout-othertoolname'
      #
      # This parameter is required - either from the including class or instance
      # configuration.
      #
      attr_accessor :pkg_name

      ##
      # The default RubyGem version that we will use when requesting our executable.
      #
      # Classes that include the Task can set the default value for this property
      # at the class level with:
      #
      #     set :pkg_version, '>= 1.0.3'
      #
      # But that value can be overriden on each instance like:
      #
      #     executable = SomeToolTask.new
      #     too.pkg_version = '>= 2.0.0'
      #
      # This parameter is required - either from the including class or instance
      # configuration.
      #
      attr_accessor :pkg_version

      ##
      # The default Sprout executable that we will use for this executable.
      #
      # Classes that include the Task can set the default value for this property
      # at the class level with:
      #
      #     set :executable, :mxmlc
      #
      # But that value can be overriden on each instance like:
      #
      #     executable = SomeToolTask.new
      #     too.executable :compc
      #
      # This parameter is required - either from the including class or instance
      # configuration.
      #
      attr_accessor :executable

      private

      def initialize_parameters
        self.class.static_parameter_collection.each do |declaration|
          param = initialize_parameter declaration

          short       = param.short_name
          long        = param.option_parser_name
          description = param.description
          delimiter   = param.delimiter
          type        = param.option_parser_type_output

          option_parser.on short, "#{long}#{delimiter}#{type}", description do |value|
            if(param.is_a?(CollectionParam) && delimiter == '+=')
              eval "self.#{param.name} << '#{value}'"
            else
              self.send "#{param.name}=", value
            end
          end
        end

      end

      def initialize_parameter declaration
        name   = declaration[:name]
        type   = declaration[:type]

        name_s = name.to_s

        # First ensure the named accessor doesn't yet exist...
        if(parameter_hash_includes? name)
          raise Sprout::Errors::ExecutableError.new("ToolTask.add_param called with existing parameter name: #{name_s}")
        end

        create_parameter declaration
      end

      def create_parameter declaration
        param = ParameterFactory.create declaration[:type]
        param.belongs_to = self
          
        begin
          declaration.each_pair do |key, value|
            param.send "#{key}=", value
          end
        rescue ArgumentError
          raise Sprout::Errors::UsageError.new "Unexpected parameter option encountered with: #{key} and value: #{value}"
        end

        raise Sprout::Errors::UsageError.new "Parameter name is required" if(param.name.nil?)

        param_hash[param.name.to_sym] = param
        params << param

        # Expose this parameter to commandline arguments:
        #add_commandline_param param

        param
      end

      def initialize_defaults
        self.class.static_default_value_collection.each_pair do |name, value|
          self.send "#{name}=", value
        end
      end

      def parameter_hash_includes? name
        param_hash.has_key? name.to_sym
      end

      def validate
        params.each do |param|
          param.validate
        end
      end

      def option_parser
        @option_parser
      end

    end
  end
end

