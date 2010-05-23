require 'sprout/executable/param'
require 'sprout/executable/collection_param'
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

  ##
  # The Sprout::Executable module is essentially a Domain Specific Language
  # for describing Command Line Interface (CLI) applications.
  #
  # This module can be included by any class, and depending on how that class
  # is used, one can either parse command line arguments into meaningful, 
  # structured data, or delegate ruby code and configuration to an existing,
  # external command line process.
  #
  # Following is an example of how one could define an executable Ruby
  # application using this module:
  #
  #   :include: ../../test/fixtures/examples/executable
  #
  # Following is an example of how one could delegate to an existing
  # command line application:
  #
  #   :include: ../../test/fixtures/examples/executable_delegate
  #
  module Executable
    DEFAULT_FILE_EXPRESSION = '/**/**/*'
    DEFAULT_PREFIX          = '--'
    DEFAULT_SHORT_PREFIX    = '-'

    extend Sprout::Concern

    module ClassMethods

      ##
      # +add_param+ is the workhorse of the Task.
      # This method is used to add new shell parameters to the executable interface.
      #
      # +name+ is a symbol or string that represents the parameter that you would like to add
      # such as :debug or :source_path.
      #
      # +type+ is a class reference of the Executable::Param that you'd like to use. 
      # At the time of this writing, add_param will accept 2 class references that 
      # do not extend Param - String and File. The ParameterFactory will automatically
      # resolve these to the correct data type when they are created.
      #
      #   Boolean  true or false
      #   File     Path to a file
      #   Number   Any number
      #   Path     Path to a directory
      #   String   Any string value
      #   Url      Basic URL
      #
      #   Files    Collection of files
      #   Paths    Collection of directories
      #   Strings  Collection of arbitrary strings
      #   Urls     Collection of URLs
      #
      # Be sure to check out the Sprout::Executable::Param class to learn more about
      # working with executable parameters.
      #
      # Once parameters have been added using the +add_param+ method, clients
      # can set and get those parameters from any newly created executable instance,
      # or from the command line.
      #
      # In the case of an executable delegate, parameter values will be sent to the 
      # command line executable in the order they are added using +add_param+.
      #
      # In the case of a Ruby executable, command line parameters will be interpreted
      # in the order they are defined using +add_param+.
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

      ##
      # Configure the executable instance to output failure messages to
      # stderr and abort with non-zero response.
      attr_accessor :abort_on_failure

      attr_reader :param_hash
      attr_reader :params
      attr_reader :name
      attr_reader :prerequisites

      def initialize
        super
        @abort_on_failure     = true
        @appended_args        = nil
        @prepended_args       = nil
        @param_hash           = {}
        @params               = []
        @prerequisites        = []
        @option_parser        = OptionParser.new
        @default_prefix       = DEFAULT_PREFIX
        @default_short_prefix = DEFAULT_SHORT_PREFIX
        initialize_parameters
        initialize_defaults
      end

      def parse commandline_options
        begin
          option_parser.parse commandline_options
          validate unless help_requested? commandline_options
        rescue StandardError => e
          handle_parse_error e
        end
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
      # with command line arguments.
      #
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
      # The default command line prefix that should be used in front of parameter
      # names.
      #
      # The default value for this parameter is '--', but some command line
      # applications (like MXMLC) prefer '-'.
      #
      attr_accessor :default_prefix
      
      ##
      # The default command line prefix for short name parameters.
      #
      # This value defaults to '-', but can be changed to whatever a particular
      # tool prefers.
      #
      attr_accessor :default_short_prefix

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

      def help_requested? options
        options.include? '--help'
      end

      def handle_parse_error error
        if(abort_on_failure)
          parts = []
          parts << nil
          parts << "[ERROR - #{error.class.name}] #{error.message}"
          parts << nil
          parts << option_parser.to_s
          parts << nil
          abort parts.join("\n")
        else
          raise error
        end
      end

      def initialize_parameters
        add_help_param
        self.class.static_parameter_collection.each do |declaration|
          param = initialize_parameter declaration
          short = param.option_parser_short_name

          option_parser.on short, 
                           param.option_parser_declaration, 
                           param.description do |value|
            if(param.is_a?(CollectionParam) && param.delimiter == '+=')
              eval "self.#{param.name} << '#{value}'"
            else
              self.send "#{param.name}=", value
            end
          end
        end
      end

      def add_help_param
        option_parser.on '--help', 'Display this help message' do
          puts option_parser.to_s
          exit
        end
      end

      def initialize_parameter declaration
        name   = declaration[:name]
        name_s = name.to_s
        type   = declaration[:type]

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

        # Expose this parameter to command line arguments:
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

