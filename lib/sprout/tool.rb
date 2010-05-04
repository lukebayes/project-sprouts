require 'sprout/tool/parameter_factory'
require 'sprout/tool/collection_param'
require 'sprout/tool/tool_param'
require 'sprout/tool/boolean_param'
require 'sprout/tool/string_param'
require 'sprout/tool/strings_param'
require 'sprout/tool/file_param'
require 'sprout/tool/files_param'
require 'sprout/tool/path_param'
require 'sprout/tool/paths_param'
require 'sprout/tool/symbols_param'
require 'sprout/tool/urls_param'

module Sprout

  module Tool
    DEFAULT_FILE_EXPRESSION = '/**/**/*'

    extend Concern

    module ClassMethods

      # +add_param+ is the workhorse of the Tool support.
      # This method is used to add new shell parameters to the tool interface.
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
      # Be sure to check out the Sprout::ToolParam class to learn more about
      # block editing the parameters.
      #
      # Once parameters have been added using the +add_param+ method, clients
      # can set and get those parameters from any newly created tool instance.
      #
      # Parameters will be sent to the commandline tool in the order they are
      # added using +add_param+.
      #
      def add_param(name, type, &block) # :yields: Sprout::ToolParam
        parameter_declarations << { :name => name, :type => type, :block => block }

        # define the setter:
        define_method("#{name.to_s}=") do |value|
          param_hash[name].value = value
        end

        # define the getter:
        define_method(name) do     
          param_hash[name].value
        end
      end
      
      def add_param_alias new_name, old_name

        # define the setter:
        define_method("#{new_name.to_s}=") do |value|
          param_hash[old_name].value = value
        end

        # define the getter:
        define_method(new_name) do     
          param_hash[old_name].value
        end
      end

      def parameter_declarations
        @parameter_declarations ||= []
      end
    end

    module InstanceMethods

      attr_reader :param_hash
      attr_reader :params

      def initialize
        super
        @preprocessed_path = nil
        @prepended_args    = nil
        @appended_args     = nil
        @default_gem_name  = nil
        @default_gem_path  = nil
        @param_hash        = {}
        @params            = []
        initialize_parameters
      end

      # Create a string that represents this configured tool for shell execution
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

      def default_file_expression
        @default_file_expression ||= Sprout::Tool::DEFAULT_FILE_EXPRESSION
      end

      private

      def initialize_parameters
        self.class.parameter_declarations.each do |options|
          create_parameter options
        end
      end

      def create_parameter options
        name = options[:name]
        type = options[:type]
        block = options[:block]

        name_s = name.to_s

        # First ensure the named accessor doesn't yet exist...
        if(parameter_hash_includes? name)
          raise Sprout::Errors::ToolError.new("Tool.add_param called with existing parameter name: #{name_s}")
        end

        param = ParameterFactory.create type do |p|
          p.belongs_to = self
          p.name = name_s
          p.type = type

          # Forward the parameter to the provided
          # closure:
          block.call p unless block.nil?
        end

        param_hash[param.name.to_sym] = param
        params << param
      end

      def parameter_hash_includes? name
        param_hash.has_key? name.to_sym
      end

      def validate
        params.each do |param|
          param.validate
        end
      end

    end
  end
end

