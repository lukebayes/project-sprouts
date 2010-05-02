require 'sprout/tool/task_param'
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
    extend Concern

    module ClassMethods

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
      # Parameters will be sent to the commandline tool in the order they are
      # added using +add_param+.
      #
      def add_param(name, type, &block) # :yields: Sprout::TaskParam
        name = name.to_s

        # First ensure the named accessor doesn't yet exist...
        if(param_hash[name])
          raise Sprout::Errors::ToolTaskError.new("TaskBase.add_param called with existing parameter name: #{name}")
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

      def param_hash
        @param_hash ||= {}
      end

      # An Array of all parameters that have been added to this Tool.
      def params
        @params ||= []
      end

      def create_param(type)
        return eval("#{type.to_s.capitalize}Param.new")
      end
      
    end

    module InstanceMethods

      def initialize
        super
        @preprocessed_path = nil
        @prepended_args    = nil
        @appended_args     = nil
        @default_gem_name  = nil
        @default_gem_path  = nil
        initialize_task
      end

      # Create a string that represents this configured tool for shell execution
      def to_shell
        return @to_shell_proc.call(self) if(!@to_shell_proc.nil?)

        result = []
        result << @prepended_args unless @prepended_args.nil?
        self.class.params.each do |param|
          if(param.visible?)
            result << param.to_shell
          end
        end
        result << @appended_args unless @appended_args.nil?
        return result.join(' ')
      end

      def clean_name(name)
        name.gsub(/=$/, '')
      end

      def respond_to?(name)
        result = super
        if(!result)
          result = self.class.param_hash.has_key? name.to_s
        end
        return result
      end

      def method_missing(name, *args)
        name = name.to_s
        cleaned = clean_name(name)

        if(!respond_to?(cleaned))
          raise NoMethodError.new("undefined method '#{name}' for #{self.class}", name)
        end

        param = self.class.param_hash[cleaned]

        matched = name =~ /=$/
        if(matched)
          param.value = args.shift
        elsif(param)
          param.value
        else
          raise Sprout::Errors::ToolTaskError.new("method_missing called with undefined parameter [#{name}]")
        end
      end

      protected

      def initialize_task
      end

      def validate
        self.class.params.each do |param|
          param.validate
        end
      end

    end
  end
end

