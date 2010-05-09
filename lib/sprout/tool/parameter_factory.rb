require 'sprout/tool/collection_param'
require 'sprout/tool/param'
require 'sprout/tool/boolean_param'
require 'sprout/tool/number_param'
require 'sprout/tool/string_param'
require 'sprout/tool/strings_param'
require 'sprout/tool/file_param'
require 'sprout/tool/files_param'
require 'sprout/tool/path_param'
require 'sprout/tool/paths_param'
require 'sprout/tool/symbols_param'
require 'sprout/tool/url_param'
require 'sprout/tool/urls_param'

##
# Used to create new Parameter instances for Sprout::Tool.
#
class Sprout::Tool::ParameterFactory

  class << self

    ##
    # Create an new Parameter by type.
    #
    # @type Symbol
    #
    def create type
      param = instantiate type
      yield param if block_given?
      param
    end

    private

    def instantiate type
      param = resolve_sprout_parameter type.to_s
      return param unless param.nil?

      param = resolve_unknown_parameter(type.to_s)
      return param unless param.nil?
      raise Sprout::Errors::UsageError.new "ParameterFactory.create called with unknown type: #{type}"
    end

    def resolve_sprout_parameter type_str
      type_str = "#{type_str}_param"
      attempt_to_instantiate Sprout, type_str
    end

    def resolve_unknown_parameter type_str
      [type_str, type_str + "_param"].each do |type|
        instance = attempt_to_instantiate Object, type
        return instance unless instance.nil?
      end
      nil
    end

    def attempt_to_instantiate from, type
      camel_cased = type.to_s.camel_case
      begin
        constructor = from.const_get camel_cased
        return constructor.new unless constructor.nil?
      rescue NameError
        return nil
      end
    end
  end
end

